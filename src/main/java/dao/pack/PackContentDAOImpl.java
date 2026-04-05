package dao.pack;

import java.util.List;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import dto.pack.PackContentDTO;

@Repository // DAO 빈으로 등록
public class PackContentDAOImpl implements PackContentDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NAMESPACE = "pack_content_mapper."; // 매퍼 네임스페이스

    @Override
    public List<PackContentDTO> selectPackContentsByPackSeq(int packSeq) {
        return sqlSession.selectList(NAMESPACE + "selectPackContentsByPackSeq", packSeq);
    }
}