package service.pve; // (★) pve 패키지 사용

import java.util.Map;

public interface PveScenarioService {

    /**
     * 특정 사용자의 PVE 스테이지 상태 맵을 조회합니다. (1단계 ~ 10단계)
     * 키: 스테이지 레벨(Integer), 값: 상태 문자열("CLEARED", "IN_PROGRESS", "LOCKED")
     * @param userId 사용자 ID
     * @return 스테이지 상태 맵
     */
    Map<Integer, String> getStageStatusMapForUser(String userId);

    // 필요하다면, 스테이지 클리어 시 상태를 업데이트하는 메서드 등 추가
    // boolean clearStage(String userId, int stageLevel);
}