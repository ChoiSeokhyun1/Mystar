package dao.mission;

import java.util.List;
import dto.mission.DailyMissionDTO;
import dto.mission.UserDailyMissionDTO;

public interface DailyMissionDAO {
    
    // 활성화된 모든 일일 미션 조회
    List<DailyMissionDTO> selectAllActiveMissions();
    
    // 특정 미션 조회
    DailyMissionDTO selectMissionById(int missionId);
    
    // 유저의 오늘 미션 진행 상황 조회 (미션 정보 포함)
    List<UserDailyMissionDTO> selectUserMissionsToday(String userId);
    
    // 유저 미션 진행 상황 조회 (단일)
    UserDailyMissionDTO selectUserMission(String userId, int missionId);
    
    // 유저 미션 진행 상황 생성 (오늘 처음 접속 시)
    int insertUserMission(UserDailyMissionDTO userMission);
    
    // 미션 진행도 업데이트
    int updateMissionProgress(String userId, int missionId, int currentCount);
    
    // 미션 완료 처리
    int completeMission(String userId, int missionId);
    
    // 보상 수령 처리
    int claimReward(String userId, int missionId);
    
    // 오늘 날짜의 미션 데이터가 있는지 확인
    int checkTodayMissionExists(String userId);
    
    // 유저의 오래된 미션 데이터 삭제 (리셋)
    int deleteOldUserMissions(String userId);
    
    // 완료 가능한 미션 수 조회
    int countCompletableMissions(String userId);
    
    // 수령 가능한 보상 개수 조회
    int countClaimableRewards(String userId);
}