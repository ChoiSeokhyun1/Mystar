package service.user;

import javax.servlet.http.HttpSession; // HttpSession import
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service; // @Service import
import dao.user.UserDAO; // UserDAO import
import dto.user.UserDTO; // UserDTO import

@Service // Spring Service 빈으로 등록
public class LoginServiceImpl implements LoginService {

    @Autowired 
    private UserDAO userDAO; // UserDAO 인터페이스 타입으로 주입 (Impl 자동 연결)

    @Override
    public UserDTO login(UserDTO userDTO, HttpSession session) {
        UserDTO loginUser = userDAO.selectUserForLogin(userDTO);
        
        if (loginUser != null) {
            session.setAttribute("loginUser", loginUser); 
            loginUser.setUserPw(null); 
        }
        
        return loginUser;
    }

    @Override
    public void logout(HttpSession session) {
        session.removeAttribute("loginUser");

    }
}