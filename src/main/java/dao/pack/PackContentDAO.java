package dao.pack;

import java.util.List;
import dto.pack.PackContentDTO;

/**
 * 팩 내용물(선수 목록 및 확률) 관련 데이터베이스 작업을 위한 인터페이스.
 */
public interface PackContentDAO {

    /**
     * 특정 팩에 포함된 모든 선수 목록과 확률 정보를 조회합니다.
     * @param packSeq 조회할 팩의 고유 번호.
     * @return PackContentDTO 리스트.
     */
    List<PackContentDTO> selectPackContentsByPackSeq(int packSeq);
}