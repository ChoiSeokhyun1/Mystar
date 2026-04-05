package service.player;

import java.util.List;
import java.util.Random;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import dao.player.OwnedPlayerDAO;
import dto.player.OwnedPlayerDTO;

/**
 * 자정(00:00 KST)마다 모든 보유 선수의 컨디션을 균등 확률로 랜덤 변경
 */
@Component
public class ConditionScheduler {

    private static final String[] CONDITIONS = {"PEAK", "GOOD", "NORMAL", "TIRED", "WORST"};
    private final Random random = new Random();

    @Autowired
    private OwnedPlayerDAO ownedPlayerDAO;

    @Scheduled(cron = "0 0 0 * * *", zone = "Asia/Seoul")
    public void randomizeAllConditions() {
        List<Integer> seqs = ownedPlayerDAO.selectAllOwnedPlayerSeqs();
        for (int seq : seqs) {
            String newCondition = CONDITIONS[random.nextInt(CONDITIONS.length)];
            OwnedPlayerDTO dto = new OwnedPlayerDTO();
            dto.setOwnedPlayerSeq(seq);
            dto.setCondition(newCondition);
            ownedPlayerDAO.updateConditionBySeq(dto);
        }
        System.out.println("[ConditionScheduler] 컨디션 갱신 완료: " + seqs.size() + "명");
    }
}