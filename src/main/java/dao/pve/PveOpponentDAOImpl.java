package dao.pve;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import dto.pve.PveOpponentInfoDTO;

import java.util.List;
import java.util.Map;

@Repository
public class PveOpponentDAOImpl implements PveOpponentDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NAMESPACE = "pveopponent_mapper"; // (★) . 제거

    @Override
    public List<PveOpponentInfoDTO> findOpponentEntryBySubstage(Map<String, Object> params) {
        // (★) 호출 시 . 추가
        return sqlSession.selectList(NAMESPACE + ".selectOpponentEntryBySubstage", params);
    }
}