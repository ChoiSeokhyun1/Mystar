package service.pve;

import dao.pve.PveOpponentDAO;
import dao.pve.PveSubstageDAO;
import dao.pve.PveProgressDAO; // (★) 1. 메인 스테이지 DAO 임포트
import dao.user.UserDAO; // (★) 유저 재화 처리를 위한 UserDAO 임포트
import dto.pve.PveOpponentInfoDTO; 
import dto.pve.PveSubstageDTO;
import dto.pve.UserPveSubstageProgressDTO;
import dto.pve.UserPveProgressDTO; // (★) 2. 메인 스테이지 DTO 임포트
import dto.pve.PveStageMapDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class PveSubstageServiceImpl implements PveSubstageService {

    // (★) 3. PveProgressDAO 주입
    @Autowired
    private PveProgressDAO pveProgressDAO; 

    @Autowired
    private PveSubstageDAO pveSubstageDAO;

    @Autowired
    private PveOpponentDAO pveOpponentDAO; 
    
    // (★) UserDAO 주입 - 크리스탈 지급을 위함
    @Autowired
    private UserDAO userDAO;
    
    // (★) 서브스테이지 클리어 보상 크리스탈 (상수)
    private static final int SUBSTAGE_CLEAR_CRYSTAL_REWARD = 100;
    
    // (★) 4. MAX_STAGE_LEVEL 상수 제거 (동적 처리)

    @Override
    public List<Map<String, Object>> getSubstageListWithStatus(String userId, int stageLevel) {
        // 1. 하위 스테이지 마스터 정보
        List<PveSubstageDTO> allSubstages = pveSubstageDAO.findSubstagesByStageLevel(stageLevel);

        // 2. 사용자 클리어 기록
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("stageLevel", stageLevel);
        List<UserPveSubstageProgressDTO> clearedProgress = pveSubstageDAO.findClearedSubstagesForUser(params);

        // 3. 빠른 조회를 위한 Set
        Set<Integer> clearedSubLevels = clearedProgress.stream()
                                          .map(UserPveSubstageProgressDTO::getSubLevel)
                                          .collect(Collectors.toSet());

        // 4. 최종 결과 리스트
        List<Map<String, Object>> resultList = new ArrayList<>();
        boolean previousSubStageCleared = true; // 1-1은 항상 IN_PROGRESS

        // 5. 상태 결정 로직
        for (PveSubstageDTO substage : allSubstages) {
            Map<String, Object> subStageData = new HashMap<>();
            subStageData.put("subLevel", substage.getSubLevel());
            subStageData.put("title", substage.getSubTitle());
            subStageData.put("opponentTeamName", substage.getOpponentTeamName() != null ? substage.getOpponentTeamName() : "AI Team");
            
            String status;
            boolean isCleared = clearedSubLevels.contains(substage.getSubLevel());

            if (isCleared) {
                status = "CLEARED";
                previousSubStageCleared = true;
            } else if (previousSubStageCleared) {
                status = "IN_PROGRESS";
                previousSubStageCleared = false;
            } else {
                status = "LOCKED";
                previousSubStageCleared = false;
            }
            subStageData.put("status", status);
            resultList.add(subStageData);
        }
        return resultList;
    }

    
    /**
     * 5세트 맵 정보 조회
     */
    @Override
    public List<PveStageMapDTO> getMapsForSubstage(int stageLevel, int subLevel) {
        Map<String, Object> params = new HashMap<>();
        params.put("stageLevel", stageLevel);
        params.put("subLevel", subLevel);
        return pveSubstageDAO.findMapsBySubstage(params);
    }
    
    /**
     * AI 엔트리 목록 조회 (PveOpponentInfoDTO 반환)
     */
    @Override
    public List<PveOpponentInfoDTO> getOpponentEntryForSubstage(int stageLevel, int subLevel) {
        Map<String, Object> params = new HashMap<>();
        params.put("stageLevel", stageLevel);
        params.put("subLevel", subLevel);
        return pveOpponentDAO.findOpponentEntryBySubstage(params); 
    }

    /**
     * (★★) [최종 구현] AI 엔트리 목록을 Map<SetNumber, DTO> 형태로 조회합니다.
     */
    @Override
    public Map<Integer, PveOpponentInfoDTO> getOpponentMapForSubstage(int stageLevel, int subLevel) {
        
        // 1. 기존 List 메서드를 재사용하여 리스트를 가져옵니다.
        List<PveOpponentInfoDTO> opponentEntryList = getOpponentEntryForSubstage(stageLevel, subLevel);
        
        if (opponentEntryList == null) {
            return new HashMap<>();
        }
        
        // 2. Stream API를 사용하여 List를 Map<SetNumber, DTO>으로 변환합니다.
        Map<Integer, PveOpponentInfoDTO> aiPlayerMap = opponentEntryList.stream()
                .filter(p -> p.getSetNumber() > 0) 
                .collect(Collectors.toMap(
                        PveOpponentInfoDTO::getSetNumber, 
                        p -> p,
                        (existing, replacement) -> existing
                ));
        
        return aiPlayerMap;
    }

    /**
     * 하위 스테이지 상세 정보 (AI 팀 이름 등) 조회
     */
    @Override
    public PveSubstageDTO getSubstageDetails(int stageLevel, int subLevel) {
        Map<String, Object> params = new HashMap<>();
        params.put("stageLevel", stageLevel);
        params.put("subLevel", subLevel);
        return pveSubstageDAO.findSubstageDetails(params);
    }
    
    
    
    /**
     * (★★★) [수정됨] 하위 스테이지 클리어 처리 + 크리스탈 보상 지급
     */
    @Override
    @Transactional(rollbackFor = Exception.class) // (★) 트랜잭션 처리
    public boolean clearSubstage(String userId, int stageLevel, int subLevel) throws Exception {
        
        UserPveSubstageProgressDTO progressDto = new UserPveSubstageProgressDTO();
        progressDto.setUserId(userId);
        progressDto.setStageLevel(stageLevel);
        progressDto.setSubLevel(subLevel);

        int insertedRows = pveSubstageDAO.createSubstageClearRecord(progressDto);
        
        if (insertedRows > 0) {
            // 크리스탈/훈련포인트 지급 — 실패해도 클리어 기록은 유지
            try {
                Map<String, Object> crystalParams = new HashMap<>();
                crystalParams.put("userId", userId);
                crystalParams.put("amount", SUBSTAGE_CLEAR_CRYSTAL_REWARD);
                userDAO.updateUserCrystal(crystalParams);
            } catch (Exception e) {
                System.err.println("크리스탈 지급 실패 (클리어는 유지): " + e.getMessage());
            }
            try {
                Map<String, Object> trainParams = new HashMap<>();
                trainParams.put("userId", userId);
                trainParams.put("amount", 1);
                userDAO.updateUserTrainPoint(trainParams);
            } catch (Exception e) {
                System.err.println("훈련포인트 지급 실패 (클리어는 유지): " + e.getMessage());
            }

            // 메인 스테이지 클리어 체크 — 실패해도 서브스테이지 클리어는 유지
            try {
                checkAndProcessMainStageClear(userId, stageLevel);
            } catch (Exception e) {
                System.err.println("메인 스테이지 클리어 처리 실패 (서브스테이지 클리어는 유지): " + e.getMessage());
                e.printStackTrace();
            }
            return true;
        }
        
        return false;
    }
    
    /**
     * (★★★★★) 5. [신규] 메인 스테이지 클리어/잠금 해제 헬퍼 메서드 (★★★★★)
     */
    private void checkAndProcessMainStageClear(String userId, int stageLevel) throws Exception {
        
        // 1. 이 메인 스테이지(예: 1)의 '총' 하위 스테이지 개수 확인 (동적)
        List<PveSubstageDTO> allSubstages = pveSubstageDAO.findSubstagesByStageLevel(stageLevel);
        int totalSubstageCount = allSubstages.size();

        if (totalSubstageCount == 0) {
            // 하위 스테이지가 없는 경우 (데이터 오류)
            return; 
        }

        // 2. 이 메인 스테이지(예: 1)에서 '클리어한' 하위 스테이지 개수 확인
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("stageLevel", stageLevel);
        List<UserPveSubstageProgressDTO> clearedProgress = pveSubstageDAO.findClearedSubstagesForUser(params);
        int clearedSubstageCount = clearedProgress.size();

        // 3. (핵심) 두 숫자가 일치하는지 확인 (예: 10 == 10)
        if (totalSubstageCount == clearedSubstageCount) {
            // (★) 메인 스테이지(1) 클리어!
            
            // 4. (Action 1) 현재 스테이지(1)를 CLEARED로 업데이트
            UserPveProgressDTO clearDto = new UserPveProgressDTO();
            clearDto.setUserId(userId);
            clearDto.setStageLevel(stageLevel);
            clearDto.setStageStatus("CLEARED");
            
            // PveProgressDAO를 사용하여 USER_PVE_PROGRESS 테이블 업데이트
            UserPveProgressDTO currentProgress = pveProgressDAO.findSinglePveProgress(userId, stageLevel);
            
            if (currentProgress == null) {
                 // 1-1을 깨는 순간 1 스테이지는 IN_PROGRESS로 생성되었어야 하지만, 방어로직
                 pveProgressDAO.createPveProgress(clearDto);
            } else if (!"CLEARED".equals(currentProgress.getStageStatus())) {
                 // IN_PROGRESS -> CLEARED로 변경
                 pveProgressDAO.modifyPveProgress(clearDto);
            }
            
            // 5. (Action 2) (★) 다음 스테이지(2)가 "존재하는지" 확인 후 잠금 해제
            int nextStageLevel = stageLevel + 1;
            
            // (★) DB에서 다음 스테이지(예: 2)의 하위 스테이지가 1개라도 있는지 확인
            List<PveSubstageDTO> nextStageSubstages = pveSubstageDAO.findSubstagesByStageLevel(nextStageLevel);
            
            // (★) 다음 스테이지가 존재한다면 (하위 스테이지가 1개 이상 있다면)
            if (nextStageSubstages != null && !nextStageSubstages.isEmpty()) { 
                
                // 다음 스테이지(2)가 (LOCKED 상태이거나) 아예 기록이 없는지 확인
                UserPveProgressDTO nextStageProgress = pveProgressDAO.findSinglePveProgress(userId, nextStageLevel);
                
                // 다음 스테이지(2) 기록이 아예 없는 경우에만 IN_PROGRESS로 생성
                if (nextStageProgress == null) { 
                    UserPveProgressDTO unlockDto = new UserPveProgressDTO();
                    unlockDto.setUserId(userId);
                    unlockDto.setStageLevel(nextStageLevel);
                    unlockDto.setStageStatus("IN_PROGRESS"); // (★) 잠금 해제
                    pveProgressDAO.createPveProgress(unlockDto);
                }
            }
        }
        // (두 숫자가 일치하지 않으면 아무것도 하지 않고 종료)
    }
}