// MatchRecordDAOImpl.java (수정된 구현체)
package dao.record;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import dto.record.MatchRecordDTO;
import dto.record.PlayerRecordSummaryDTO;
import dto.record.PlayerStatRankDTO;

@Repository
public class MatchRecordDAOImpl implements MatchRecordDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NAMESPACE = "match_record_mapper.";

    @Override
    public int insertMatchRecord(MatchRecordDTO record) {
        return sqlSession.insert(NAMESPACE + "insertMatchRecord", record);
    }

    @Override
    public PlayerRecordSummaryDTO selectRecordSummary(int ownedPlayerSeq) {
        return sqlSession.selectOne(NAMESPACE + "selectRecordSummary", ownedPlayerSeq);
    }

    @Override
    public List<MatchRecordDTO> selectRecentMatches(int ownedPlayerSeq, int limit) {
        Map<String, Object> params = new HashMap<>();
        params.put("ownedPlayerSeq", ownedPlayerSeq);
        params.put("limit", limit);
        return sqlSession.selectList(NAMESPACE + "selectRecentMatches", params);
    }

    @Override
    public PlayerStatRankDTO selectMostPlayedPlayer(String userId) {
        return sqlSession.selectOne(NAMESPACE + "selectMostPlayedPlayer", userId);
    }

    @Override
    public PlayerStatRankDTO selectBestWinRatePlayer(String userId) {
        return sqlSession.selectOne(NAMESPACE + "selectBestWinRatePlayer", userId);
    }

    @Override
    public PlayerStatRankDTO selectMostWinsPlayer(String userId) {
        return sqlSession.selectOne(NAMESPACE + "selectMostWinsPlayer", userId);
    }
}