package dao.pve;

import dto.pve.PveSubstageDTO;
import dto.pve.UserPveSubstageProgressDTO;
import dto.pve.PveStageMapDTO; // (★) 새로 만든 DTO 임포트
import java.util.List;
import java.util.Map; // Map 사용

public interface PveSubstageDAO {

    /**
     * 특정 메인 스테이지에 속한 모든 하위 스테이지 목록을 조회합니다. (subLevel 오름차순)
     * @param stageLevel 메인 스테이지 레벨
     * @return PveSubstageDTO 리스트
     */
    List<PveSubstageDTO> findSubstagesByStageLevel(int stageLevel);

    /**
     * 특정 사용자가 특정 메인 스테이지에서 클리어한 하위 스테이지 목록을 조회합니다.
     * @param params Map<String, Object> - "userId" (String)와 "stageLevel" (int) 포함
     * @return UserPveSubstageProgressDTO 리스트 (클리어한 기록만)
     */
    List<UserPveSubstageProgressDTO> findClearedSubstagesForUser(Map<String, Object> params);

    /**
     * 사용자의 하위 스테이지 클리어 기록을 삽입합니다.
     * @param progressDto userId, stageLevel, subLevel 포함 (isCleared, clearedAt은 DB 기본값 사용)
     * @return 영향받은 행 수 (성공 시 1)
     */
    int createSubstageClearRecord(UserPveSubstageProgressDTO progressDto);

    /**
     * (★) [신규] 특정 하위 스테이지의 5세트 맵 정보를 조회합니다. (세트 번호 오름차순)
     * @param params Map<String, Object> - "stageLevel" (int)와 "subLevel" (int) 포함
     * @return PveStageMapDTO 리스트 (5개 세트)
     */
    List<PveStageMapDTO> findMapsBySubstage(Map<String, Object> params);
    
    PveSubstageDTO findSubstageDetails(Map<String, Object> params);
    
    /**
     * (★) [신규] TBL_PVE_SUBSTAGES에 정의된 가장 높은 스테이지 레벨을 조회합니다.
     * @return 가장 높은 스테이지 레벨, 스테이지가 없으면 null
     */
    Integer findMaxStageLevel();
}