// MatchRecordDAO.java (수정된 인터페이스)
package dao.record;

import java.util.List;
import dto.record.MatchRecordDTO;
import dto.record.PlayerRecordSummaryDTO;
import dto.record.PlayerStatRankDTO;
import org.apache.ibatis.annotations.Param;

public interface MatchRecordDAO {
    int insertMatchRecord(MatchRecordDTO record);

    PlayerRecordSummaryDTO selectRecordSummary(int ownedPlayerSeq);
    List<MatchRecordDTO> selectRecentMatches(@Param("ownedPlayerSeq") int ownedPlayerSeq, @Param("limit") int limit);

    // 유저 선수단 랭킹
    PlayerStatRankDTO selectMostPlayedPlayer(String userId);
    PlayerStatRankDTO selectBestWinRatePlayer(String userId);
    PlayerStatRankDTO selectMostWinsPlayer(String userId);
}