package dao.admin;

import dto.pack.PackDTO;
import dto.player.PlayerDTO;
import dto.pve.PveOpponentInfoDTO;
import dto.pve.PveStageMapDTO;
import dto.pve.PveSubstageDTO;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class AdminDAOImpl implements AdminDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NS = "admin_mapper.";

    @Override
    public List<Integer> findAllStageLevels() {
        return sqlSession.selectList(NS + "selectAllStageLevels");
    }

    @Override
    public int findMaxStageLevel() {
        Integer result = sqlSession.selectOne(NS + "selectMaxStageLevel");
        return result != null ? result : 0;
    }

    @Override
    public List<PveSubstageDTO> findSubstagesByStageLevel(int stageLevel) {
        return sqlSession.selectList(NS + "selectSubstagesByStageLevel", stageLevel);
    }

    @Override
    public PveSubstageDTO findSubstageDetail(Map<String, Object> params) {
        return sqlSession.selectOne(NS + "selectSubstageDetail", params);
    }

    @Override
    public int findMaxSubLevel(int stageLevel) {
        Integer result = sqlSession.selectOne(NS + "selectMaxSubLevel", stageLevel);
        return result != null ? result : 0;
    }

    @Override
    public int insertSubstage(PveSubstageDTO dto) {
        return sqlSession.insert(NS + "insertSubstage", dto);
    }

    @Override
    public int updateSubstage(PveSubstageDTO dto) {
        return sqlSession.update(NS + "updateSubstage", dto);
    }

    @Override
    public int deleteSubstage(Map<String, Object> params) {
        return sqlSession.delete(NS + "deleteSubstage", params);
    }

    @Override
    public int deleteOpponentsByStage(int stageLevel) {
        return sqlSession.delete(NS + "deleteOpponentsByStage", stageLevel);
    }

    @Override
    public int deleteOpponentsBySubstage(Map<String, Object> params) {
        return sqlSession.delete(NS + "deleteOpponentsBySubstage", params);
    }

    @Override
    public int deleteStage(int stageLevel) {
        return sqlSession.delete(NS + "deleteStage", stageLevel);
    }

    @Override
    public int deleteProgressByStage(int stageLevel) {
        return sqlSession.delete(NS + "deleteProgressByStage", stageLevel);
    }

    @Override
    public int deleteSubstageProgressByStage(int stageLevel) {
        return sqlSession.delete(NS + "deleteSubstageProgressByStage", stageLevel);
    }

    @Override
    public int deleteSubstageProgressBySubstage(Map<String, Object> params) {
        return sqlSession.delete(NS + "deleteSubstageProgressBySubstage", params);
    }

    @Override
    public List<PveOpponentInfoDTO> findOpponentsBySubstage(Map<String, Object> params) {
        return sqlSession.selectList(NS + "selectOpponentsBySubstage", params);
    }

    @Override
    public int deleteOpponentBySet(Map<String, Object> params) {
        return sqlSession.delete(NS + "deleteOpponentBySet", params);
    }

    @Override
    public int deleteAllOpponentsBySubstage(Map<String, Object> params) {
        return sqlSession.delete(NS + "deleteAllOpponentsBySubstage", params);
    }

    @Override
    public int insertOpponent(Map<String, Object> params) {
        return sqlSession.insert(NS + "insertOpponent", params);
    }

    @Override
    public List<Map<String, Object>> findAllMaps() {
        return sqlSession.selectList(NS + "selectAllMaps");
    }

    @Override
    public List<PveStageMapDTO> findSubstageMaps(Map<String, Object> params) {
        return sqlSession.selectList(NS + "selectSubstageMaps", params);
    }

    @Override
    public int deleteSubstageMapBySet(Map<String, Object> params) {
        return sqlSession.delete(NS + "deleteSubstageMapBySet", params);
    }

    @Override
    public int insertSubstageMap(Map<String, Object> params) {
        return sqlSession.insert(NS + "insertSubstageMap", params);
    }

    @Override
    public List<PlayerDTO> findAllPlayers() {
        return sqlSession.selectList(NS + "selectAllPlayers");
    }

    @Override
    public List<PackDTO> findAllPacksForAdmin() {
        return sqlSession.selectList(NS + "selectAllPacksForAdmin");
    }

    @Override
    public PackDTO findPackBySeq(int packSeq) {
        return sqlSession.selectOne(NS + "selectPackBySeq", packSeq);
    }

    @Override
    public int insertPack(PackDTO dto) {
        return sqlSession.insert(NS + "insertPack", dto);
    }

    @Override
    public int updatePack(PackDTO dto) {
        return sqlSession.update(NS + "updatePack", dto);
    }

    @Override
    public int togglePackAvailable(Map<String, Object> params) {
        return sqlSession.update(NS + "togglePackAvailable", params);
    }

    @Override
    public int deleteAllPackContentsByPack(int packSeq) {
        return sqlSession.delete(NS + "deleteAllPackContentsByPack", packSeq);
    }

    @Override
    public int deletePack(int packSeq) {
        return sqlSession.delete(NS + "deletePack", packSeq);
    }

    @Override
    public List<Map<String, Object>> findPacksWithProbByPlayerSeq(int playerSeq) {
        return sqlSession.selectList(NS + "selectPacksWithProbByPlayerSeq", playerSeq);
    }

    @Override
    public List<PackDTO> findAllPacks() {
        return sqlSession.selectList(NS + "selectAllPacks");
    }

    @Override
    public List<Integer> findPlayerSeqsByPack(int packSeq) {
        return sqlSession.selectList(NS + "selectPlayerSeqsByPack", packSeq);
    }

    @Override
    public List<Map<String, Object>> findAllBuilds() {
        return sqlSession.selectList("pveopponent_mapper.selectAllBuilds");
    }

    @Override
    public List<PackDTO> findPacksByPlayerSeq(int playerSeq) {
        return sqlSession.selectList(NS + "selectPacksByPlayerSeq", playerSeq);
    }

    @Override
    public int insertPackContent(Map<String, Object> params) {
        return sqlSession.insert(NS + "insertPackContent", params);
    }

    @Override
    public int deletePackContent(Map<String, Object> params) {
        return sqlSession.delete(NS + "deletePackContent", params);
    }

    @Override
    public int deleteAllPackContentsByPlayer(int playerSeq) {
        return sqlSession.delete(NS + "deleteAllPackContentsByPlayer", playerSeq);
    }

    @Override
    public List<PlayerDTO> findAllPlayersForAdmin() {
        return sqlSession.selectList(NS + "selectAllPlayersForAdmin");
    }

    @Override
    public int insertPlayer(PlayerDTO dto) {
        return sqlSession.insert(NS + "insertPlayer", dto);
    }

    @Override
    public int updatePlayer(PlayerDTO dto) {
        return sqlSession.update(NS + "updatePlayer", dto);
    }

    @Override
    public int deleteMatchRecordsByPlayer(int playerSeq) {
        return sqlSession.delete(NS + "deleteMatchRecordsByPlayer", playerSeq);
    }

    @Override
    public int deletePveEntriesByPlayer(int playerSeq) {
        return sqlSession.delete(NS + "deletePveEntriesByPlayer", playerSeq);
    }

    @Override
    public int deleteOwnedPlayersByPlayer(int playerSeq) {
        return sqlSession.delete(NS + "deleteOwnedPlayersByPlayer", playerSeq);
    }

    @Override
    public int deletePveOpponentsByPlayer(int playerSeq) {
        return sqlSession.delete(NS + "deletePveOpponentsByPlayer", playerSeq);
    }

    @Override
    public int deletePlayer(int playerSeq) {
        return sqlSession.delete(NS + "deletePlayer", playerSeq);
    }
}