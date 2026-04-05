package dao.user;

import dto.user.UserDTO;
import java.util.Map; // (★★) [신규] Map 임포트 추가

public interface UserDAO {
    // 기존 로그인 메소드
    UserDTO selectUserForLogin(UserDTO userDTO);

    /** ★ 추가: 사용자 재화 정보 조회 */
    UserDTO selectUserCurrency(String userId);

    /** ★ 추가: 사용자 재화 차감 */
    int updateUserCurrency(UserDTO userDTO); // 차감할 금액 계산 후 UserDTO에 담아 전달
    
    /**
     * (★★) [신규] 유저의 재화(크리스탈)를 증가시킵니다. (스테이지 클리어 보상용)
     * @param params Map - "userId" (String)와 "amount" (int) 포함
     * @return DML(UPDATE)이 적용된 행의 수
     */
    int updateUserCrystal(Map<String, Object> params);

    /** 훈련 포인트 증감 */
    int updateUserTrainPoint(Map<String, Object> params);
}