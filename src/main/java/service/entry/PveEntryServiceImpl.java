package service.entry;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import dao.entry.PveEntryDAO;
import dto.entry.PveEntryDTO;
import dto.player.OwnedPlayerInfoDTO;

@Service // Service 빈으로 등록
public class PveEntryServiceImpl implements PveEntryService {

    @Autowired
    private PveEntryDAO pveEntryDAO;

    @Override
    public List<OwnedPlayerInfoDTO> getPveEntry(String userId) {
        // DAO를 호출하여 엔트리에 등록된 선수 정보 목록을 가져옴
        return pveEntryDAO.selectPveEntryPlayersByUserId(userId);
    }

    /**
     * 엔트리 업데이트 로직.
     * 기존 엔트리를 모두 삭제하고, 새로운 엔트리를 삽입합니다.
     * 이 모든 과정은 하나의 트랜잭션으로 처리됩니다.
     */
    @Override
    @Transactional(rollbackFor = Exception.class) // 오류 발생 시 롤백
    public boolean updatePveEntry(String userId, List<Integer> ownedPlayerSeqList) throws Exception {
        
        // 1. 유효성 검사 (최대 9명으로 수정)
        if (ownedPlayerSeqList == null || ownedPlayerSeqList.size() > 9) {
            throw new Exception("엔트리 선수 목록이 유효하지 않습니다. (최대 9명)");
        }

        try {
            // 2. 해당 유저의 기존 PVE 엔트리 모두 삭제
            pveEntryDAO.deletePveEntryByUserId(userId);
            
            // 3. 새로운 엔트리 목록을 순서대로(슬롯 1번부터) 삽입
            int slotNumber = 1;
            for (Integer ownedPlayerSeq : ownedPlayerSeqList) {
                if (ownedPlayerSeq != null && ownedPlayerSeq > 0) { // 유효한 선수 ID인 경우
                    PveEntryDTO entry = new PveEntryDTO();
                    entry.setUserId(userId);
                    entry.setOwnedPlayerSeq(ownedPlayerSeq);
                    entry.setSlotNumber(slotNumber);
                    
                    pveEntryDAO.insertPveEntry(entry);
                    
                    slotNumber++; // 다음 슬롯 번호
                }
            }
            
            return true; // 모든 작업 성공

        } catch (Exception e) {
            // DB 제약 조건 위반(예: UK_USER_OWNED_PLAYER) 등으로 오류 발생 시
            e.printStackTrace();
            // @Transactional에 의해 자동으로 롤백됨
            throw new Exception("엔트리 저장 중 오류가 발생했습니다. (중복 선수 등): " + e.getMessage());
        }
    }
}