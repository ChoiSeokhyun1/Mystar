package service.pve; // (★) pve 패키지 사용

import dao.pve.PveProgressDAO; // (★) DAO 인터페이스 임포트
import dao.pve.PveSubstageDAO;
import dto.pve.UserPveProgressDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;


import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class PveScenarioServiceImpl implements PveScenarioService {

    @Autowired
    private PveProgressDAO pveProgressDAO; // (★) DAO 주입
    
    @Autowired
    private PveSubstageDAO pveSubstageDAO; // (★) 1. PveSubstageDAO 주입

    // private static final int MAX_STAGE_LEVEL = 10; // (★) 총 스테이지 수

    @Override
    public Map<Integer, String> getStageStatusMapForUser(String userId) {
        // 1. DB에서 사용자 진행 상태 리스트 가져오기
        List<UserPveProgressDTO> progressList = pveProgressDAO.findPveProgressByUserId(userId);

        // 2. 리스트를 Map으로 변환
        Map<Integer, String> dbProgressMap = progressList.stream()
                .collect(Collectors.toMap(UserPveProgressDTO::getStageLevel, UserPveProgressDTO::getStageStatus));

        // (★) 3. DB에서 실제 최대 스테이지 레벨 조회
        Integer maxStageFromDb = pveSubstageDAO.findMaxStageLevel();
        int maxStage = (maxStageFromDb != null && maxStageFromDb > 0) ? maxStageFromDb : 1; // 최소 1

        // 4. 최종 결과 Map (1단계 ~ maxStage단계)을 생성합니다.
        Map<Integer, String> stageStatusMap = new HashMap<>();
        boolean previousStageCleared = true; 

        // (★) 5. MAX_STAGE_LEVEL 대신 maxStage 변수 사용
        for (int i = 1; i <= maxStage; i++) {
            String dbStatus = dbProgressMap.get(i); 

            if ("CLEARED".equals(dbStatus)) {
                stageStatusMap.put(i, "CLEARED");
                previousStageCleared = true; 
            } else if (previousStageCleared) {
                stageStatusMap.put(i, "IN_PROGRESS");
                previousStageCleared = false; 
            } else {
                stageStatusMap.put(i, "LOCKED");
                previousStageCleared = false;
            }
        }
        
        // (★) 6. maxStage 변수 사용
        if (progressList.isEmpty() && maxStage >= 1) {
             stageStatusMap.put(1, "IN_PROGRESS");
        }

        return stageStatusMap;
    }

    /*
    // (★) 스테이지 클리어 예시 (DAO 사용)
    @Override
    @Transactional
    public boolean clearStage(String userId, int clearedStageLevel) {
        if (clearedStageLevel < 1 || clearedStageLevel > MAX_STAGE_LEVEL) {
            return false;
        }

        UserPveProgressDTO currentProgress = pveProgressDAO.findSinglePveProgress(userId, clearedStageLevel);

        UserPveProgressDTO updateDto = new UserPveProgressDTO();
        updateDto.setUserId(userId);
        updateDto.setStageLevel(clearedStageLevel);
        updateDto.setStageStatus("CLEARED");

        int updatedRows;
        if (currentProgress == null) {
            updatedRows = pveProgressDAO.createPveProgress(updateDto);
        } else if (!"CLEARED".equals(currentProgress.getStageStatus())) {
            updatedRows = pveProgressDAO.modifyPveProgress(updateDto);
        } else {
            updatedRows = 1;
        }

        if (updatedRows != 1) {
            return false;
        }

        int nextStageLevel = clearedStageLevel + 1;
        if (nextStageLevel <= MAX_STAGE_LEVEL) {
            UserPveProgressDTO nextStageProgress = pveProgressDAO.findSinglePveProgress(userId, nextStageLevel);
            if (nextStageProgress == null) {
                UserPveProgressDTO insertNextDto = new UserPveProgressDTO();
                insertNextDto.setUserId(userId);
                insertNextDto.setStageLevel(nextStageLevel);
                insertNextDto.setStageStatus("IN_PROGRESS"); // 다음 스테이지 잠금 해제
                pveProgressDAO.createPveProgress(insertNextDto);
            }
        }
        return true;
    }
    */
}