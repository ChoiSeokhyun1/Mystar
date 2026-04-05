package service.mission;

import java.util.List;
import dto.mission.UserDailyMissionDTO;

public interface DailyMissionService {
    
    /**
     * 유저의 오늘 미션 목록 조회 (오늘 처음 접속이면 초기화)
     */
    List<UserDailyMissionDTO> getUserMissionsToday(String userId);
    
    /**
     * 미션 진행도 증가
     * @param userId 유저 ID
     * @param missionType 미션 타입 (PVE_WIN, PVE_PLAY, GACHA, ENHANCE, LOGIN)
     * @param increment 증가량 (기본 1)
     */
    void incrementMissionProgress(String userId, String missionType, int increment);
    
    /**
     * 미션 보상 수령
     * @param userId 유저 ID
     * @param missionId 미션 ID
     * @return 성공 여부 및 보상 크리스탈 양
     */
    int claimMissionReward(String userId, int missionId);
    
    /**
     * 수령 가능한 보상 개수 조회 (사이드바 뱃지용)
     */
    int getClaimableRewardCount(String userId);
    
    /**
     * 미션 초기화 (오늘 처음 접속 시)
     */
    void initializeTodayMissions(String userId);
}