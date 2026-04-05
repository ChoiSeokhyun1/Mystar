package dao.user;

import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;
import dto.user.UserDTO;
import java.util.Map; // (★★) [신규] Map 임포트 추가

@Repository
public class UserDAOImpl implements UserDAO {

    @Autowired
    private SqlSessionTemplate sqlSession;

    private static final String NAMESPACE = "user_mapper.";

    @Override
    public UserDTO selectUserForLogin(UserDTO userDTO) {
        return sqlSession.selectOne(NAMESPACE + "findUserByIdAndPassword", userDTO);
    }

    /** ★ 추가 */
    @Override
    public UserDTO selectUserCurrency(String userId) {
        return sqlSession.selectOne(NAMESPACE + "selectUserCurrency", userId);
    }

    /** ★ 추가 */
    @Override
    public int updateUserCurrency(UserDTO userDTO) {
        // userDTO에는 userId와 차감 후 남은 crystal, gold 값이 들어있어야 함
        return sqlSession.update(NAMESPACE + "updateUserCurrency", userDTO);
    }
    
    /**
     * (★★) [신규] 유저의 재화(크리스탈)를 증가시킵니다. (스테이지 클리어 보상용)
     */
    @Override
    public int updateUserCrystal(Map<String, Object> params) {
        // params에는 "userId"와 "amount"가 들어있어야 함
        return sqlSession.update(NAMESPACE + "updateUserCrystal", params);
    }

    @Override
    public int updateUserTrainPoint(Map<String, Object> params) {
        return sqlSession.update(NAMESPACE + "updateUserTrainPoint", params);
    }
}