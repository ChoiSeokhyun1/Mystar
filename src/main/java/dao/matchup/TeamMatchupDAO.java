package dao.matchup;

import dto.matchup.TeamMatchupBonusDTO;
import java.util.List;
import java.util.Map;

/**
 * 3:3 팀 종족 상성 보너스 DAO
 */
public interface TeamMatchupDAO {

    /** 전체 목록 조회 (관리 화면용) */
    List<TeamMatchupBonusDTO> selectAllMatchupBonuses();

    /** 특정 매칭 조합으로 보너스 배율 조회 */
    TeamMatchupBonusDTO selectMatchupBonus(Map<String, Object> params);

    /** 삽입 (UPSERT) */
    int insertMatchupBonus(TeamMatchupBonusDTO dto);

    /** 수정 */
    int updateMatchupBonus(TeamMatchupBonusDTO dto);

    /** 삭제 */
    int deleteMatchupBonus(int matchupId);
}