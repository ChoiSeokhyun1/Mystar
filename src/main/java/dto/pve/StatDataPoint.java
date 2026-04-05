package dto.pve;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor // (★★) @Data는 기본 생성자가 필요할 수 있습니다.
public class StatDataPoint {
    private double time;
    private double myAttack;
    private double myDefense;
    private double aiAttack;
    private double aiDefense;

    // (★★) 데이터를 쉽게 추가하기 위한 생성자
    public StatDataPoint(double time, double myAttack, double myDefense, double aiAttack, double aiDefense) {
        this.time = time;
        this.myAttack = myAttack;
        this.myDefense = myDefense;
        this.aiAttack = aiAttack;
        this.aiDefense = aiDefense;
    }
}