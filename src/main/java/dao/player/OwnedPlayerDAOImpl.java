package dao.player;

import java.util.List;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import dto.player.OwnedPlayerDTO;
import dto.player.OwnedPlayerInfoDTO;

@Repository
public class OwnedPlayerDAOImpl implements OwnedPlayerDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NAMESPACE = "owned_player_mapper.";

    @Override
    public int insertOwnedPlayer(OwnedPlayerDTO ownedPlayer) {
        return sqlSession.insert(NAMESPACE + "insertOwnedPlayer", ownedPlayer);
    }

    @Override
    public List<OwnedPlayerInfoDTO> selectOwnedPlayersByUserId(String userId) {
        return sqlSession.selectList(NAMESPACE + "selectOwnedPlayersByUserId", userId);
    }

    @Override
    public OwnedPlayerInfoDTO selectOwnedPlayerDetails(int ownedPlayerSeq) {
        return sqlSession.selectOne(NAMESPACE + "selectOwnedPlayerDetails", ownedPlayerSeq);
    }
    
    @Override
    public OwnedPlayerDTO selectOwnedPlayer(int ownedPlayerSeq) {
        return sqlSession.selectOne(NAMESPACE + "selectOwnedPlayer", ownedPlayerSeq);
    }
    
    @Override
    public int updatePlayerStats(OwnedPlayerDTO ownedPlayer) {
        return sqlSession.update(NAMESPACE + "updatePlayerStats", ownedPlayer);
    }

    @Override
    public int updateWinStreak(OwnedPlayerDTO player) {
        return sqlSession.update(NAMESPACE + "updateWinStreak", player);
    }

    @Override
    public int updateConditionBySeq(OwnedPlayerDTO player) {
        return sqlSession.update(NAMESPACE + "updateConditionBySeq", player);
    }

    @Override
    public List<Integer> selectAllOwnedPlayerSeqs() {
        return sqlSession.selectList(NAMESPACE + "selectAllOwnedPlayerSeqs");
    }

    @Override
    public int deleteOwnedPlayer(int ownedPlayerSeq) {
        return sqlSession.delete(NAMESPACE + "deleteOwnedPlayer", ownedPlayerSeq);
    }

    @Override
    public int updateEnhanceStats(OwnedPlayerDTO player) {
        return sqlSession.update(NAMESPACE + "updateEnhanceStats", player);
    }

    @Override
    public int updateEnhanceStreak(OwnedPlayerDTO player) {
        return sqlSession.update(NAMESPACE + "updateEnhanceStreak", player);
    }

    @Override
    public List<OwnedPlayerDTO> selectMaterialCandidates(OwnedPlayerDTO condition) {
        return sqlSession.selectList(NAMESPACE + "selectMaterialCandidates", condition);
    }
}