package dao.pve;

import dto.pve.PveSubstageDTO;
import dto.pve.UserPveSubstageProgressDTO;
import dto.pve.PveStageMapDTO; // (★) 새로 만든 DTO 임포트
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class PveSubstageDAOImpl implements PveSubstageDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    // (★) 요청하신 형식으로 수정: 인터페이스 이름 + "."
    private static final String NAMESPACE = "pveSubstage_Mapper.";

    @Override
    public List<PveSubstageDTO> findSubstagesByStageLevel(int stageLevel) {
        return sqlSession.selectList(NAMESPACE + "selectSubstagesByStageLevel", stageLevel);
    }

    @Override
    public List<UserPveSubstageProgressDTO> findClearedSubstagesForUser(Map<String, Object> params) {
        return sqlSession.selectList(NAMESPACE + "selectClearedSubstagesForUser", params);
    }

    @Override
    public int createSubstageClearRecord(UserPveSubstageProgressDTO progressDto) {
        return sqlSession.insert(NAMESPACE + "insertSubstageClearRecord", progressDto);
    }
    
    /**
     * (★) [신규] 특정 하위 스테이지의 5세트 맵 정보 조회
     */
    @Override
    public List<PveStageMapDTO> findMapsBySubstage(Map<String, Object> params) {
        return sqlSession.selectList(NAMESPACE + "selectMapsBySubstage", params);
    }

    /**
     * (★) [신규] 특정 하위 스테이지 1개 상세 정보 조회
     */
    @Override
    public PveSubstageDTO findSubstageDetails(Map<String, Object> params) {
        return sqlSession.selectOne(NAMESPACE + "selectSubstageDetails", params);
    }
    // 필요하다면 다른 메서드 구현
    // @Override
    // public PveSubstageDTO findSubstageByKey(int stageLevel, int subLevel) {
    //     Map<String, Object> params = new HashMap<>();
    //     params.put("stageLevel", stageLevel);
    //     params.put("subLevel", subLevel);
    //     return sqlSession.selectOne(NAMESPACE + "selectSubstageByKey", params);
    // }
    
    /**
     * (★) [신규] 최대 스테이지 레벨 조회
     */
    @Override
    public Integer findMaxStageLevel() {
        return sqlSession.selectOne(NAMESPACE + "selectMaxStageLevel");
    }
}