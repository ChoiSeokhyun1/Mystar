package dao.entry; // 엔트리 DAO 패키지

import java.util.List;
import dto.entry.PveEntryDTO;
import dto.player.OwnedPlayerInfoDTO; // 보유 선수 상세 정보 DTO import

public interface PveEntryDAO {

    /**
     * 특정 유저의 PVE 엔트리에 등록된 *선수들의 상세 정보* 목록을 조회합니다.
     * TBL_PVE_ENTRY, TBL_OWNED_PLAYERS, TBL_PLAYERS 3개 테이블 JOIN이 필요합니다.
     * @param userId 유저 ID
     * @return 1군 엔트리에 등록된 선수들의 상세 정보 리스트 (OwnedPlayerInfoDTO 사용)
     */
    List<OwnedPlayerInfoDTO> selectPveEntryPlayersByUserId(String userId);

    /**
     * 특정 유저의 PVE 엔트리 전체를 삭제합니다. (저장 전 초기화용)
     * @param userId 유저 ID
     * @return 삭제된 행(row)의 수
     */
    int deletePveEntryByUserId(String userId);

    /**
     * PVE 엔트리에 선수 한 명을 특정 슬롯에 추가합니다.
     * @param pveEntryDTO (userId, ownedPlayerSeq, slotNumber 포함)
     * @return INSERT 성공 시 1
     */
    int insertPveEntry(PveEntryDTO pveEntryDTO);
}