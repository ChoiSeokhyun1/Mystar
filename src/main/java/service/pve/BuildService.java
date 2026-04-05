package service.pve;

import dto.pve.BuildDTO;
import dto.pve.BuildUnitDTO;
import java.util.List;

public interface BuildService {
    // 빌드 CRUD
    int createBuild(BuildDTO build);      // 빌드 + 유닛 한번에 저장
    int modifyBuild(BuildDTO build);      // 빌드 수정 (유닛 전체 재삽입)
    int removeBuild(int buildId);

    BuildDTO getBuildById(int buildId);
    List<BuildDTO> getBuildsByUserId(String userId);

    // 선수-빌드 연결
    int assignBuildToPlayer(int ownedPlayerSeq, int buildId);
    int unassignBuildFromPlayer(int ownedPlayerSeq, int buildId);
    List<BuildDTO> getBuildsByOwnedPlayerSeq(int ownedPlayerSeq);

    // 빌드 전적 기록 (세트 결과 반영)
    void recordBuildResult(int buildId, boolean isWin);
}