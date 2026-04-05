package dto.pack; // 팩 관련 DTO 패키지

import lombok.Data;

@Data
public class PackContentDTO {
    private int packContentSeq; // 팩 내용 고유 번호 (NUMBER -> int)
    private int packSeq;        // 팩 고유 번호 (FK, NUMBER -> int)
    private int playerSeq;      // 선수 고유 번호 (FK, NUMBER -> int)
    private double drawProbability; // 개별 선수 뽑기 확률 (NUMBER -> double)
}