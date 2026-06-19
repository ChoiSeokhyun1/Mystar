package dao.player;

import java.util.List;
import dto.player.PlayerTraitDTO;

public interface PlayerTraitDAO {

    /** userId의 모든 소유 선수 + 특성 정보 조회 (LEFT JOIN) */
    List<PlayerTraitDTO> getTraitListByUserId(String userId);

    /** 특정 소유 선수의 특성 조회 */
    PlayerTraitDTO getTraitByOwnedPlayerSeq(int ownedPlayerSeq);

    /** 특성 INSERT (신규 생성) */
    int insertTrait(PlayerTraitDTO dto);

    /** 특성 가중치 UPDATE */
    int updateTraitWeights(PlayerTraitDTO dto);

    /** 특성 레벨 UPDATE */
    int updateTraitLevel(PlayerTraitDTO dto);
}
