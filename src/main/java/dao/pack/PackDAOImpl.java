package dao.pack;

import java.util.List;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import dto.pack.PackDTO;

@Repository // DAO 빈으로 등록
public class PackDAOImpl implements PackDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NAMESPACE = "pack_mapper."; // 매퍼 네임스페이스

    @Override
    public List<PackDTO> selectAvailablePacks() {
        // 네임스페이스 + id 로 XML 쿼리 실행
        return sqlSession.selectList(NAMESPACE + "selectAvailablePacks");
    }

    @Override
    public PackDTO selectPackBySeq(int packSeq) {
        return sqlSession.selectOne(NAMESPACE + "selectPackBySeq", packSeq);
    }
}