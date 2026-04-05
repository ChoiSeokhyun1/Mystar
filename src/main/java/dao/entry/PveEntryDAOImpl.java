package dao.entry;

import java.util.List;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import dto.entry.PveEntryDTO;
import dto.player.OwnedPlayerInfoDTO;

@Repository // DAO 빈으로 등록
public class PveEntryDAOImpl implements PveEntryDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NAMESPACE = "pve_entry_mapper."; // 매퍼 네임스페이스

    @Override
    public List<OwnedPlayerInfoDTO> selectPveEntryPlayersByUserId(String userId) {
        // 1군 엔트리에 등록된 선수들의 '상세 정보'를 가져옴
        return sqlSession.selectList(NAMESPACE + "selectPveEntryPlayersByUserId", userId);
    }

    @Override
    public int deletePveEntryByUserId(String userId) {
        // 엔트리 저장 전, 기존 엔트리 모두 삭제
        return sqlSession.delete(NAMESPACE + "deletePveEntryByUserId", userId);
    }

    @Override
    public int insertPveEntry(PveEntryDTO pveEntryDTO) {
        // 새 엔트리 슬롯 추가
        return sqlSession.insert(NAMESPACE + "insertPveEntry", pveEntryDTO);
    }
}