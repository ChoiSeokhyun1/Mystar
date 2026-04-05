package service.gacha;

import dto.player.PlayerDTO; // 뽑힌 선수 정보를 반환하기 위해 import

public interface GachaService {

    /**
     * 지정된 팩에서 선수를 뽑습니다. (1회 뽑기 기준)
     *
     * @param userId 뽑기를 시도하는 유저 ID
     * @param packSeq 뽑을 팩의 고유 번호
     * @return 뽑힌 선수의 PlayerDTO 객체. 재화 부족 등 오류 발생 시 null 반환.
     * @throws Exception DB 오류 등 예외 발생 시
     */
    PlayerDTO drawSinglePlayer(String userId, int packSeq) throws Exception;

    // 필요하다면 10회 뽑기 메소드도 추가할 수 있습니다.
    // List<PlayerDTO> drawMultiplePlayers(String userId, int packSeq, int count) throws Exception;
}