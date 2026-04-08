package dao.pve;

import dto.pve.BuildDTO;
import java.util.List;
import java.util.Map;

public interface BuildDAO {
    // 빌드 CRUD
    int insertBuild(BuildDTO build);
    int updateBuild(BuildDTO build);
    int deleteBuild(int buildId);
    int nullifyOpponentBuildId(int buildId);
    int deleteOwnedBuildsByBuildId(int buildId);
    BuildDTO selectBuildById(int buildId);
    List<BuildDTO> selectBuildsByUserId(String userId);
    List<BuildDTO> selectAllBuilds();
    
    // 종족별 빌드 조회 (대본 관리용)
    List<BuildDTO> selectBuildsByRace(String race);

    // 유닛 설정 (호환성)
    int deleteBuildUnitsByBuildId(int buildId);

    // 선수-빌드 연결
    int insertOwnedBuild(Map<String, Object> params);
    int deleteOwnedBuild(Map<String, Object> params);
    List<BuildDTO> selectBuildsByOwnedPlayerSeq(int ownedPlayerSeq);

    // 빌드 전적 업데이트
    int incrementBuildWin(int buildId);
    int incrementBuildLose(int buildId);
}