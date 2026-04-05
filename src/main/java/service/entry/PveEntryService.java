package service.entry; // 엔트리 Service 패키지

import java.util.List;
import dto.player.OwnedPlayerInfoDTO; // 엔트리 선수 정보 DTO

public interface PveEntryService {

    /**
     * 특정 유저의 현재 PVE 엔트리(1군)에 등록된 선수 목록을 조회합니다.
     * @param userId 유저 ID
     * @return 1군 엔트리에 등록된 선수들의 상세 정보 리스트 (슬롯 번호 순 정렬)
     */
    List<OwnedPlayerInfoDTO> getPveEntry(String userId);

    /**
     * 특정 유저의 PVE 엔트리를 업데이트(덮어쓰기)합니다.
     * @param userId 유저 ID
     * @param ownedPlayerSeqList 엔트리에 등록할 보유 선수 고유 번호(ownedPlayerSeq)의 리스트.
     * (리스트 순서가 슬롯 1번부터 7번까지를 의미함)
     * @return 저장 성공 여부
     * @throws Exception 예외 발생 시
     */
    boolean updatePveEntry(String userId, List<Integer> ownedPlayerSeqList) throws Exception;
}