package dao.pve;

import dto.pve.BattleSessionDTO;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public class BattleSessionDAOImpl implements BattleSessionDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    // (참고) Mapper XML의 namespace와 일치해야 합니다.
    private static final String NAMESPACE = "battlesession_mapper."; 

    @Override
    public BattleSessionDTO selectActiveBattle(Map<String, Object> params) {
        // XML ID: selectActiveBattle
        return sqlSession.selectOne(NAMESPACE + "selectActiveBattle", params);
    }
    
    @Override
    public void insertNewBattle(BattleSessionDTO dto) {
        // XML ID: insertNewBattle
        sqlSession.insert(NAMESPACE + "insertNewBattle", dto);
    }
    
    @Override
    public int updateBattleProgress(Map<String, Object> params) {
        // XML ID: updateBattleProgress
        return sqlSession.update(NAMESPACE + "updateBattleProgress", params);
    }
    
    /**
     * (★★) [수정] Service의 '승리' 분기에서 호출됩니다.
     */
    @Override
    public int completePveBattleSession(Map<String, Object> params) {
        // 이전 COMPLETED 레코드가 있으면 먼저 삭제 (UNIQUE 제약 방지)
        sqlSession.update(NAMESPACE + "completePveBattleSession", params);
        // IN_PROGRESS → COMPLETED 업데이트
        return sqlSession.update(NAMESPACE + "completePveBattleSessionUpdate", params);
    }

    /**
     * (★★) [추가] Service의 '패배' 분기에서 호출됩니다.
     */
    @Override
    public int deletePveBattleSession(Map<String, Object> params) {
        return sqlSession.delete(NAMESPACE + "deletePveBattleSession", params);
    }

    @Override
    public int updateSetResultsData(Map<String, Object> params) {
        return sqlSession.update(NAMESPACE + "updateSetResultsData", params);
    }
}