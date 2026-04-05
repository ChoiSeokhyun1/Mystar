package dao.pve; // (★) pve 패키지 사용

import dto.pve.UserPveProgressDTO;
import org.mybatis.spring.SqlSessionTemplate; // (★) SqlSessionTemplate 임포트
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.HashMap; // (★) Map 임포트
import java.util.List;
import java.util.Map; // (★) Map 임포트

@Repository // Spring이 DAO 빈으로 인식하도록 설정
public class PveProgressDAOImpl implements PveProgressDAO {

    @Autowired
    private SqlSessionTemplate sqlSession; // (★) SqlSessionTemplate 주입

    // (★) Mapper XML의 namespace와 일치해야 합니다.
    private static final String NAMESPACE = "pveProgress_Mapper.";

    @Override
    public List<UserPveProgressDTO> findPveProgressByUserId(String userId) {
        // selectList 메서드 사용, 파라미터는 userId 하나
        return sqlSession.selectList(NAMESPACE + "selectPveProgressByUserId", userId);
    }

    @Override
    public UserPveProgressDTO findSinglePveProgress(String userId, int stageLevel) {
        // 파라미터가 여러 개이므로 Map 사용
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("stageLevel", stageLevel);
        // selectOne 메서드 사용
        return sqlSession.selectOne(NAMESPACE + "selectSinglePveProgress", params);
    }

    @Override
    public int createPveProgress(UserPveProgressDTO progressDto) {
        // insert 메서드 사용, 파라미터는 DTO 객체
        return sqlSession.insert(NAMESPACE + "insertPveProgress", progressDto);
    }

    @Override
    public int modifyPveProgress(UserPveProgressDTO progressDto) {
        // update 메서드 사용, 파라미터는 DTO 객체
        return sqlSession.update(NAMESPACE + "updatePveProgress", progressDto);
    }

    // 필요하다면 다른 메서드 구현
    // @Override
    // public Integer findHighestClearedStage(String userId) {
    //     return sqlSession.selectOne(NAMESPACE + "selectHighestClearedStage", userId);
    // }
}