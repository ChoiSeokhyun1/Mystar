package dao.matchup;

import dto.matchup.TeamMatchupBonusDTO;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class TeamMatchupDAOImpl implements TeamMatchupDAO {

    private static final String NS = "matchup.TeamMatchupMapper.";

    @Autowired
    private SqlSessionTemplate sqlSession;

    @Override
    public List<TeamMatchupBonusDTO> selectAllMatchupBonuses() {
        return sqlSession.selectList(NS + "selectAll");
    }

    @Override
    public TeamMatchupBonusDTO selectMatchupBonus(Map<String, Object> params) {
        return sqlSession.selectOne(NS + "selectByCombo", params);
    }

    @Override
    public int insertMatchupBonus(TeamMatchupBonusDTO dto) {
        return sqlSession.insert(NS + "insertBonus", dto);
    }

    @Override
    public int updateMatchupBonus(TeamMatchupBonusDTO dto) {
        return sqlSession.update(NS + "updateBonus", dto);
    }

    @Override
    public int deleteMatchupBonus(int matchupId) {
        return sqlSession.delete(NS + "deleteBonus", matchupId);
    }
}