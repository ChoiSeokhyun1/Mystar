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

    // 관리자(SYSTEM) 빌드 전체 조회 (유저 전투 준비 화면용)
    List<BuildDTO> getSystemBuilds();

    // 종족 + 상대종족별 빌드 조회 (매치 빌드 선택용)
    List<BuildDTO> getBuildsByRaceAndVsRace(String race, String vsRace);

    // 선수-빌드 연결
    int assignBuildToPlayer(int ownedPlayerSeq, int buildId);
    int unassignBuildFromPlayer(int ownedPlayerSeq, int buildId);
    List<BuildDTO> getBuildsByOwnedPlayerSeq(int ownedPlayerSeq);

    // 빌드 전적 기록
    void recordBuildResult(int buildId, boolean isWin);
}