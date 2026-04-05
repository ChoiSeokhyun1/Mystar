package service.gacha;

import java.util.List;
import java.util.Random; // 확률 계산을 위한 Random 클래스 import

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // 트랜잭션 처리 import

import dao.pack.PackContentDAO;
import dao.pack.PackDAO;
import dao.player.OwnedPlayerDAO; // OwnedPlayerDAO import
import dao.player.PlayerDAO;
import dao.user.UserDAO; // UserDAO import
import dto.pack.PackContentDTO;
import dto.pack.PackDTO;
import dto.player.OwnedPlayerDTO; // OwnedPlayerDTO import
import dto.player.PlayerDTO;
import dto.user.UserDTO;

@Service // Spring Service 빈으로 등록
public class GachaServiceImpl implements GachaService {

    @Autowired private UserDAO userDAO;
    @Autowired private PackDAO packDAO;
    @Autowired private PackContentDAO packContentDAO;
    @Autowired private PlayerDAO playerDAO;
    @Autowired private OwnedPlayerDAO ownedPlayerDAO; // 새로 추가된 DAO 주입

    private Random random = new Random(); // 확률 계산용 Random 객체

    /**
     * 1회 뽑기 로직 구현
     * (★중요★) @Transactional: 재화 차감과 선수 추가가 하나의 작업 단위(트랜잭션)로 묶여야 함.
     * 중간에 오류 발생 시 모든 DB 변경 사항이 롤백됨.
     */
    @Override
    @Transactional(rollbackFor = Exception.class) // 모든 종류의 Exception 발생 시 롤백
    public PlayerDTO drawSinglePlayer(String userId, int packSeq) throws Exception {

        // 1. 사용자 재화 정보 조회
        UserDTO user = userDAO.selectUserCurrency(userId);
        if (user == null) {
            throw new Exception("사용자 정보를 찾을 수 없습니다.");
        }

        // 2. 팩 정보 조회 (가격 확인)
        PackDTO pack = packDAO.selectPackBySeq(packSeq);
        if (pack == null || !"Y".equals(pack.getIsAvailable())) {
            throw new Exception("유효하지 않거나 판매 중이지 않은 팩입니다.");
        }

        // 3. 재화 확인 및 차감
        int costCrystal = pack.getCostCrystal();
        int remainingCrystal = user.getCrystal();

        if (costCrystal > 0 && remainingCrystal < costCrystal) {
            System.out.println("크리스탈 부족"); // 실제로는 로깅 프레임워크 사용 권장
            return null; // 재화 부족 시 null 반환 (Controller에서 처리)
        }

        // 재화 차감
        if (costCrystal > 0) remainingCrystal -= costCrystal;

        // DB에 차감된 재화 업데이트
        UserDTO userUpdate = new UserDTO();
        userUpdate.setUserId(userId);
        userUpdate.setCrystal(remainingCrystal);
        int updateResult = userDAO.updateUserCurrency(userUpdate);
        if (updateResult == 0) {
            throw new Exception("재화 차감 중 오류가 발생했습니다.");
        }
        System.out.println("재화 차감 완료: Crystal=" + remainingCrystal);

        // 4. 팩 내용물 (선수 목록 및 확률) 조회
        List<PackContentDTO> contents = packContentDAO.selectPackContentsByPackSeq(packSeq);
        if (contents == null || contents.isEmpty()) {
            throw new Exception("팩에 포함된 선수가 없습니다.");
        }

        // 5. 확률 기반 선수 뽑기
        double totalProbability = 0;
        for(PackContentDTO content : contents) {
            totalProbability += content.getDrawProbability();
        }
        // 확률 총합이 1.0에 가깝지 않으면 오류 처리 (선택 사항)
        if (Math.abs(totalProbability - 1.0) > 0.00001) {
             System.err.println("경고: 팩 " + packSeq + "의 확률 총합이 1.0이 아닙니다: " + totalProbability);
             // 필요시 Exception throw
        }

        double randomValue = random.nextDouble(); // 0.0 이상 1.0 미만의 난수 생성
        double cumulativeProbability = 0.0;
        PackContentDTO selectedContent = null;

        for (PackContentDTO content : contents) {
            cumulativeProbability += content.getDrawProbability();
            if (randomValue < cumulativeProbability) {
                selectedContent = content;
                break;
            }
        }

        if (selectedContent == null) {
            // 확률 계산 오류 또는 데이터 문제 (마지막 선수라도 뽑혀야 함)
            selectedContent = contents.get(contents.size() - 1); // 안전장치: 마지막 선수 선택
            System.err.println("경고: 확률 계산 오류 발생. 마지막 선수 선택됨.");
        }

        // 6. 뽑힌 선수 마스터 정보 조회
        PlayerDTO drawnPlayer = playerDAO.selectPlayerBySeq(selectedContent.getPlayerSeq());
        if (drawnPlayer == null) {
            throw new Exception("뽑힌 선수 정보를 찾을 수 없습니다: " + selectedContent.getPlayerSeq());
        }
        System.out.println("뽑힌 선수: " + drawnPlayer.getPlayerName() + " (" + drawnPlayer.getRarity() + ")");

        // 7. 보유 선수 정보 생성 (OwnedPlayerDTO)
        OwnedPlayerDTO newOwnedPlayer = new OwnedPlayerDTO();
        newOwnedPlayer.setUserId(userId);
        newOwnedPlayer.setPlayerSeq(drawnPlayer.getPlayerSeq());
        // TBL_PLAYERS의 기본 스탯과 초기 등급(RARITY)을 복사
        newOwnedPlayer.setCurrentAttack(drawnPlayer.getStatAttack());
        newOwnedPlayer.setCurrentDefense(drawnPlayer.getStatDefense());
        newOwnedPlayer.setCurrentMacro(drawnPlayer.getStatMacro());
        newOwnedPlayer.setCurrentMicro(drawnPlayer.getStatMicro());
        newOwnedPlayer.setCurrentLuck(drawnPlayer.getStatLuck());
        newOwnedPlayer.setCurrentRarity(drawnPlayer.getRarity()); // 초기 등급 설정
        
        // (★★) [핵심 수정] 획득한 팩 ID를 DTO에 저장
        newOwnedPlayer.setAcquiredFromPackSeq(packSeq);

        // 8. TBL_OWNED_PLAYERS에 저장
        int insertResult = ownedPlayerDAO.insertOwnedPlayer(newOwnedPlayer);
        if (insertResult == 0) {
            throw new Exception("뽑은 선수를 저장하는 중 오류가 발생했습니다.");
        }
        System.out.println("선수 저장 완료: " + drawnPlayer.getPlayerName());

        // 9. 뽑힌 선수 정보 반환
        return drawnPlayer;
    }
}