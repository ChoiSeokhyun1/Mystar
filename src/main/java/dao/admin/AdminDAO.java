package dao.admin;

import dto.pack.PackDTO;
import dto.player.PlayerDTO;
import dto.pve.PveOpponentInfoDTO;
import dto.pve.PveStageMapDTO;
import dto.pve.PveSubstageDTO;

import java.util.List;
import java.util.Map;

public interface AdminDAO {

    // 스테이지
    List<Integer> findAllStageLevels();
    int findMaxStageLevel();

    // 라운드(서브스테이지)
    List<PveSubstageDTO> findSubstagesByStageLevel(int stageLevel);
    PveSubstageDTO findSubstageDetail(Map<String, Object> params);
    int findMaxSubLevel(int stageLevel);
    int insertSubstage(PveSubstageDTO dto);
    int updateSubstage(PveSubstageDTO dto);
    int deleteSubstage(Map<String, Object> params);
    int deleteOpponentsByStage(int stageLevel);
    int deleteOpponentsBySubstage(Map<String, Object> params);
    int deleteStage(int stageLevel);
    int deleteProgressByStage(int stageLevel);
    int deleteSubstageProgressByStage(int stageLevel);
    int deleteSubstageProgressBySubstage(Map<String, Object> params);

    // AI 상대 선수
    List<PveOpponentInfoDTO> findOpponentsBySubstage(Map<String, Object> params);
    int deleteOpponentBySet(Map<String, Object> params);
    int deleteAllOpponentsBySubstage(Map<String, Object> params);
    int insertOpponent(Map<String, Object> params);

    // 세트별 맵 관리
    List<Map<String, Object>> findAllMaps();
    List<PveStageMapDTO> findSubstageMaps(Map<String, Object> params);
    int deleteSubstageMapBySet(Map<String, Object> params);
    int deleteSubstageMapsByStage(int stageLevel);
    int deleteSubstageMapsBySubstage(Map<String, Object> params);
    int insertSubstageMap(Map<String, Object> params);

    // 전체 선수 목록
    List<PlayerDTO> findAllPlayers();
    int findMaxPlayerSeq();
    int findMaxPackSeq();

    // 팩 목록 / 조회
    List<PackDTO> findAllPacks();
    List<PackDTO> findAllPacksForAdmin();
    PackDTO findPackBySeq(int packSeq);
    List<Integer> findPlayerSeqsByPack(int packSeq);
    List<Map<String, Object>> findAllBuilds();
    List<PackDTO> findPacksByPlayerSeq(int playerSeq);
    List<Map<String, Object>> findPacksWithProbByPlayerSeq(int playerSeq);

    // 팩 CRUD
    int insertPack(PackDTO dto);
    int updatePack(PackDTO dto);
    int togglePackAvailable(Map<String, Object> params);
    int deleteAllPackContentsByPack(int packSeq);
    int deletePack(int packSeq);

    // 팩-선수 연결
    int insertPackContent(Map<String, Object> params);
    int deletePackContent(Map<String, Object> params);
    int deleteAllPackContentsByPlayer(int playerSeq);

    // 선수 CRUD
    List<PlayerDTO> findAllPlayersForAdmin();
    int insertPlayer(PlayerDTO dto);
    int updatePlayer(PlayerDTO dto);
    int deleteMatchRecordsByPlayer(int playerSeq);
    int deletePveEntriesByPlayer(int playerSeq);
    int deleteOwnedPlayersByPlayer(int playerSeq);
    int deletePveOpponentsByPlayer(int playerSeq);
    int deletePlayer(int playerSeq);

    // ⭐ 추가: 빌드 vs 빌드 상성 관리
    String getBuildMatchup(Map<String, Object> params);
    void saveBuildMatchup(Map<String, Object> params);
    
    // ===================== 맵 CRUD =====================
    // AdminDAO.java 에 아래 메서드를 추가하세요.
 
    List<Map<String, Object>> findAllMapsDetail();          // 이미지 URL 포함 전체 목록
    int insertMap(Map<String, Object> params);
    int updateMap(Map<String, Object> params);
    int deleteMap(String mapId);
 
    // ===================== 맵 지점 CRUD =====================
    List<dto.pve.MapPointDTO> findPointsByMapId(String mapId);
    int insertMapPoint(dto.pve.MapPointDTO dto);
    int updateMapPoint(dto.pve.MapPointDTO dto);
    int deleteMapPoint(int pointId);
    int deleteMapPointsByMapId(String mapId);
 
}