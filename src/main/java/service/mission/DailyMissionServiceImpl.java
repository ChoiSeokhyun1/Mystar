package service.mission;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import dao.mission.DailyMissionDAO;
import dao.user.UserDAO;
import dto.mission.DailyMissionDTO;
import dto.mission.UserDailyMissionDTO;

@Service
public class DailyMissionServiceImpl implements DailyMissionService {
    
    @Autowired
    private DailyMissionDAO dailyMissionDAO;
    
    @Autowired
    private UserDAO userDAO;
    
    @Override
    @Transactional
    public List<UserDailyMissionDTO> getUserMissionsToday(String userId) {
        // 1. 오래된 미션 데이터 삭제
        dailyMissionDAO.deleteOldUserMissions(userId);
        
        // 2. 오늘 미션 데이터가 있는지 확인
        int todayCount = dailyMissionDAO.checkTodayMissionExists(userId);
        
        // 3. 없으면 초기화
        if (todayCount == 0) {
            initializeTodayMissions(userId);
        }
        
        // 4. 오늘 미션 목록 조회
        return dailyMissionDAO.selectUserMissionsToday(userId);
    }
    
    @Override
    @Transactional
    public void incrementMissionProgress(String userId, String missionType, int increment) {
        // 1. 해당 타입의 모든 미션 조회
        List<UserDailyMissionDTO> allMissions = dailyMissionDAO.selectUserMissionsToday(userId);
        
        for (UserDailyMissionDTO mission : allMissions) {
            // 2. 미션 타입이 일치하고 아직 완료되지 않은 경우
            if (missionType.equals(mission.getMissionType()) && !"Y".equals(mission.getIsCompleted())) {
                int newCount = mission.getCurrentCount() + increment;
                
                // 3. 진행도 업데이트
                dailyMissionDAO.updateMissionProgress(userId, mission.getMissionId(), newCount);
                
                // 4. 목표 달성 시 완료 처리
                if (newCount >= mission.getTargetCount()) {
                    dailyMissionDAO.completeMission(userId, mission.getMissionId());
                }
            }
        }
    }
    
    @Override
    @Transactional
    public int claimMissionReward(String userId, int missionId) {
        // 1. 미션 정보 조회
        UserDailyMissionDTO mission = dailyMissionDAO.selectUserMission(userId, missionId);
        
        if (mission == null) {
            throw new IllegalArgumentException("미션을 찾을 수 없습니다.");
        }
        
        // 2. 수령 가능한지 확인
        if (!"Y".equals(mission.getIsCompleted())) {
            throw new IllegalStateException("아직 완료되지 않은 미션입니다.");
        }
        
        if ("Y".equals(mission.getIsClaimed())) {
            throw new IllegalStateException("이미 수령한 보상입니다.");
        }
        
        // 3. 보상 수령 처리
        dailyMissionDAO.claimReward(userId, missionId);
        
        // 4. 유저 크리스탈 증가
        // ★ 기존 updateUserCrystal은 amount를 받아서 자동으로 증가시킴
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("amount", mission.getRewardCrystal());  // 증가량만 전달
        userDAO.updateUserCrystal(params);
        
        return mission.getRewardCrystal();
    }
    
    @Override
    public int getClaimableRewardCount(String userId) {
        return dailyMissionDAO.countClaimableRewards(userId);
    }
    
    @Override
    @Transactional
    public void initializeTodayMissions(String userId) {
        // 모든 활성 미션 조회
        List<DailyMissionDTO> allMissions = dailyMissionDAO.selectAllActiveMissions();
        
        // 각 미션에 대해 유저 진행 상황 생성
        for (DailyMissionDTO mission : allMissions) {
            UserDailyMissionDTO userMission = new UserDailyMissionDTO();
            userMission.setUserId(userId);
            userMission.setMissionId(mission.getMissionId());
            userMission.setCurrentCount(0);
            userMission.setIsCompleted("N");
            userMission.setIsClaimed("N");
            
            try {
                dailyMissionDAO.insertUserMission(userMission);
            } catch (Exception e) {
                // 이미 존재하는 경우 무시
                System.err.println("미션 초기화 중 오류 (무시): " + e.getMessage());
            }
        }
        
        // 로그인 미션 자동 완료
        incrementMissionProgress(userId, "LOGIN", 1);
    }
}