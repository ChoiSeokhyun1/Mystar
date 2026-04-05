package dao.pve;

import dto.pve.BuildDTO;
import dto.pve.BuildUnitDTO;
import java.util.List;
import java.util.Map;

public interface BuildDAO {
    // 빌드 CRUD
    int insertBuild(BuildDTO build);
    int updateBuild(BuildDTO build);
    int deleteBuild(int buildId);
    int nullifyOpponentBuildId(int buildId);    // 빌드 삭제 전: PVE 상대 BUILD_ID → NULL
    int deleteOwnedBuildsByBuildId(int buildId); // 빌드 삭제 전: 선수-빌드 연결 제거
    BuildDTO selectBuildById(int buildId);
    List<BuildDTO> selectBuildsByUserId(String userId);

    // 유닛 설정
    int insertBuildUnit(BuildUnitDTO unit);
    int deleteBuildUnitsByBuildId(int buildId);  // 빌드 수정 시 전체 삭제 후 재삽입
    List<BuildUnitDTO> selectUnitsByBuildId(int buildId);

    // 선수-빌드 연결
    int insertOwnedBuild(Map<String, Object> params); // playerSeq, buildId
    int deleteOwnedBuild(Map<String, Object> params);
    List<BuildDTO> selectBuildsByOwnedPlayerSeq(int ownedPlayerSeq);

    // 빌드 전적 업데이트 (세트 결과 반영)
    int incrementBuildWin(int buildId);
    int incrementBuildLose(int buildId);
}