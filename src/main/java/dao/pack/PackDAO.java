package dao.pack;

import java.util.List;
import dto.pack.PackDTO;

/**
 * 팩(Pack) 정보 관련 데이터베이스 작업을 위한 인터페이스.
 */
public interface PackDAO {

    /**
     * 판매 중인 모든 팩 목록을 조회합니다.
     * @return PackDTO 리스트.
     */
    List<PackDTO> selectAvailablePacks();

    /**
     * 특정 팩의 상세 정보를 조회합니다.
     * @param packSeq 조회할 팩의 고유 번호.
     * @return PackDTO 객체, 없으면 null.
     */
    PackDTO selectPackBySeq(int packSeq);
}