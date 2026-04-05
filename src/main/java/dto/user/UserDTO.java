package dto.user;

import lombok.Data;

@Data
public class UserDTO {
    private String userId;
    private String userPw;
    private String userNick;
    private int crystal; // ★ 추가
    private int trainPoint; // 훈련 포인트
    private String teamName;
}