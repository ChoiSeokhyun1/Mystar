package dao.player;

import java.util.List;
import dto.player.OwnedPlayerDTO;
import dto.player.OwnedPlayerInfoDTO;

public interface OwnedPlayerDAO {
    // 기존 insert 메소드
    int insertOwnedPlayer(OwnedPlayerDTO ownedPlayer);

    /** 특정 유저의 보유 선수 목록 조회 (JOIN 결과) */
    List<OwnedPlayerInfoDTO> selectOwnedPlayersByUserId(String userId);

    /** 특정 보유 선수의 상세 정보 조회 (JOIN 결과) */
    OwnedPlayerInfoDTO selectOwnedPlayerDetails(int ownedPlayerSeq);

    /**
     * ★ 3:3 BO3 시뮬레이션용: 특정 유저가 소유한 선수들 중 ownedPlayerSeq 목록에 해당하는
     * 선수들의 상세 정보를 한 번에 조회합니다. (userId 일치 검증 포함 — 타인 선수 도용 방지)
     * 반환 순서는 보장되지 않으므로 호출 측에서 ownedPlayerSeq 기준으로 재정렬해야 합니다.
     */
    List<OwnedPlayerInfoDTO> selectOwnedPlayersBySeqs(java.util.Map<String, Object> params);
    
    /** ★★★ 추가: 특정 보유 선수 조회 (기본 정보만) */
    OwnedPlayerDTO selectOwnedPlayer(int ownedPlayerSeq);
    
    /** ★★★ 추가: 선수 능력치 업데이트 */
    int updatePlayerStats(OwnedPlayerDTO ownedPlayer);

    /** 연승 업데이트 */
    int updateWinStreak(OwnedPlayerDTO player);

    /** 컨디션 업데이트 */
    int updateConditionBySeq(OwnedPlayerDTO player);

    /** 전체 보유선수 seq 목록 (스케줄러용) */
    List<Integer> selectAllOwnedPlayerSeqs();

    /** ★ 강화 재료 소모: 보유 선수 삭제 */
    int deleteOwnedPlayer(int ownedPlayerSeq);

    /** ★ 강화 스탯 업데이트 */
    int updateEnhanceStats(OwnedPlayerDTO player);

    /** ★ 강화 연속 성공/실패 streak 업데이트 */
    int updateEnhanceStreak(OwnedPlayerDTO player);

    /**
     * ★ 강화 재료 후보 조회
     * 같은 userId, 같은 playerSeq, 같은 acquiredFromPackSeq, 다른 ownedPlayerSeq
     */
    List<OwnedPlayerDTO> selectMaterialCandidates(OwnedPlayerDTO condition);
}