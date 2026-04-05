package service.pve;

import dto.pve.PveOpponentInfoDTO;
import dto.pve.PveStageMapDTO;
import dto.pve.PveSubstageDTO;
import java.util.List;
import java.util.Map;

public interface PveSubstageService {

    /**
     * 특정 메인 스테이지의 하위 스테이지 목록과 사용자의 진행 상태를 결합하여 반환합니다.
     */
    List<Map<String, Object>> getSubstageListWithStatus(String userId, int stageLevel);
    
    /**
     * 특정 하위 스테이지의 5세트 맵 정보를 조회합니다.
     */
    List<PveStageMapDTO> getMapsForSubstage(int stageLevel, int subLevel);

    /**
     * 특정 하위 스테이지의 AI 엔트리 목록 (선수 정보 + 세트 번호)을 조회합니다.
     */
    List<PveOpponentInfoDTO> getOpponentEntryForSubstage(int stageLevel, int subLevel);
    
    /**
     * (★★) [신규] AI 엔트리 목록을 Map<SetNumber, DTO> 형태로 조회합니다.
     */
    Map<Integer, PveOpponentInfoDTO> getOpponentMapForSubstage(int stageLevel, int subLevel);

    /**
     * 특정 하위 스테이지의 상세 정보(AI 팀 이름 포함)를 조회합니다.
     */
    PveSubstageDTO getSubstageDetails(int stageLevel, int subLevel);
    
    
    /**
     * (★) [주석 해제 및 수정]
     * 사용자가 특정 하위 스테이지를 클리어했을 때 호출되는 메서드.
     * USER_PVE_SUBSTAGE_PROGRESS 테이블에 클리어 기록을 삽입합니다.
     * @param userId 사용자 ID
     * @param stageLevel 메인 스테이지 레벨
     * @param subLevel 하위 스테이지 번호
     * @return 성공 여부
     * @throws Exception DB 오류 발생 시
     */
    boolean clearSubstage(String userId, int stageLevel, int subLevel) throws Exception;
}