package dao.player;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import dto.player.PlayerDTO;

@Repository // DAO 빈으로 등록
public class PlayerDAOImpl implements PlayerDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NAMESPACE = "player_mapper."; // 매퍼 네임스페이스

    @Override
    public PlayerDTO selectPlayerBySeq(int playerSeq) {
        return sqlSession.selectOne(NAMESPACE + "selectPlayerBySeq", playerSeq);
    }
}