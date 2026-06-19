package dao.player;

import java.util.List;
import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import dto.player.PlayerTraitDTO;

@Repository
public class PlayerTraitDAOImpl implements PlayerTraitDAO {

    private static final String NS = "playerTrait.";

    @Autowired
    private SqlSession sqlSession;

    @Override
    public List<PlayerTraitDTO> getTraitListByUserId(String userId) {
        return sqlSession.selectList(NS + "getTraitListByUserId", userId);
    }

    @Override
    public PlayerTraitDTO getTraitByOwnedPlayerSeq(int ownedPlayerSeq) {
        return sqlSession.selectOne(NS + "getTraitByOwnedPlayerSeq", ownedPlayerSeq);
    }

    @Override
    public int insertTrait(PlayerTraitDTO dto) {
        return sqlSession.insert(NS + "insertTrait", dto);
    }

    @Override
    public int updateTraitWeights(PlayerTraitDTO dto) {
        return sqlSession.update(NS + "updateTraitWeights", dto);
    }

    @Override
    public int updateTraitLevel(PlayerTraitDTO dto) {
        return sqlSession.update(NS + "updateTraitLevel", dto);
    }
}
