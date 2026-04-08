package service.pve;

import dto.pve.BuildDTO;
import java.util.List;

public interface BuildService {
    // 빌드 CRUD
    int createBuild(BuildDTO build);
    int modifyBuild(BuildDTO build);
    int removeBuild(int buildId);

    BuildDTO getBuildById(int buildId);
    List<BuildDTO> getBuildsByUserId(String userId);
    List<BuildDTO> getAllBuilds();
    
    // 종족별 빌드 조회 (대본 관리용)
    List<BuildDTO> getBuildsByRace(String race);

    // 선수-빌드 연결
    int assignBuildToPlayer(int ownedPlayerSeq, int buildId);
    int unassignBuildFromPlayer(int ownedPlayerSeq, int buildId);
    List<BuildDTO> getBuildsByOwnedPlayerSeq(int ownedPlayerSeq);

    // 빌드 전적 기록
    void recordBuildResult(int buildId, boolean isWin);
}