package dao.pve;

// (★) PlayerDTO 대신 PveOpponentInfoDTO 임포트
import dto.pve.PveOpponentInfoDTO; 
import java.util.List;
import java.util.Map;

public interface PveOpponentDAO {

    /**
     * (★) 반환 타입을 List<PlayerDTO> -> List<PveOpponentInfoDTO> 로 변경
     */
    List<PveOpponentInfoDTO> findOpponentEntryBySubstage(Map<String, Object> params);

}