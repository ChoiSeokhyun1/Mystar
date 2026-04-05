package dao.pve; // (★) pve 패키지 사용

import dto.pve.UserPveProgressDTO;
import java.util.List;

public interface PveProgressDAO {

    /**
     * 특정 사용자의 모든 PVE 스테이지 진행 기록 조회 (stageLevel 오름차순)
     */
    List<UserPveProgressDTO> findPveProgressByUserId(String userId);

    /**
     * 특정 사용자의 특정 스테이지 진행 기록 조회
     */
    UserPveProgressDTO findSinglePveProgress(String userId, int stageLevel);

    /**
     * 새로운 PVE 진행 기록 삽입
     */
    int createPveProgress(UserPveProgressDTO progressDto);

    /**
     * 기존 PVE 진행 기록 업데이트
     */
    int modifyPveProgress(UserPveProgressDTO progressDto);

    // 필요하다면 다른 메서드 추가
    // Integer findHighestClearedStage(String userId);
}