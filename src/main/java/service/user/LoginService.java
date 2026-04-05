package service.user;

import javax.servlet.http.HttpSession; // HttpSession import
import dto.user.UserDTO; // UserDTO import

/**
 * 로그인 및 로그아웃 관련 비즈니스 로직을 위한 인터페이스.
 */
public interface LoginService {

    UserDTO login(UserDTO userDTO, HttpSession session);
    void logout(HttpSession session);

}