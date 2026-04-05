package dao.player;

import dto.player.PlayerDTO;

/**
 * 선수 정보 관련 데이터베이스 작업을 위한 인터페이스.
 */
public interface PlayerDAO {

    /**
     * 선수 고유 번호로 선수 정보를 조회합니다.
     * @param playerSeq 조회할 선수의 고유 번호.
     * @return PlayerDTO 객체, 없으면 null.
     */
    PlayerDTO selectPlayerBySeq(int playerSeq);

}