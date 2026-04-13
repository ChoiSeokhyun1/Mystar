package service.pve;

import dao.pve.BuildDAO;
import dto.pve.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class BuildServiceImpl implements BuildService {

    @Autowired private BuildDAO buildDAO;

    // ★ ScriptDAO 제거됨 — 대본/상성/가산점 시스템 폐기

    @Override
    public int createBuild(BuildDTO build) {
        return buildDAO.insertBuild(build);
    }

    @Override
    public int modifyBuild(BuildDTO build) {
        return buildDAO.updateBuild(build);
    }

    @Override
    public int removeBuild(int buildId) {
        buildDAO.nullifyOpponentBuildId(buildId);
        buildDAO.deleteOwnedBuildsByBuildId(buildId);
        buildDAO.deleteBuildUnitsByBuildId(buildId);
        return buildDAO.deleteBuild(buildId);
    }

    @Override
    public BuildDTO getBuildById(int buildId) {
        return buildDAO.selectBuildById(buildId);
    }

    @Override
    public List<BuildDTO> getBuildsByUserId(String userId) {
        return buildDAO.selectBuildsByUserId(userId);
    }

    @Override
    public List<BuildDTO> getAllBuilds() {
        return buildDAO.selectAllBuilds();
    }

    @Override
    public List<BuildDTO> getBuildsByRace(String race) {
        return buildDAO.selectBuildsByRace(race);
    }

    @Override
    public List<BuildDTO> getSystemBuilds() {
        return buildDAO.selectSystemBuilds();
    }

    @Override
    public List<BuildDTO> getBuildsByRaceAndVsRace(String race, String vsRace) {
        Map<String, Object> params = new HashMap<>();
        params.put("race", race);
        params.put("vsRace", vsRace);
        return buildDAO.selectBuildsByRaceAndVsRace(params);
    }

    @Override
    public int assignBuildToPlayer(int ownedPlayerSeq, int buildId) {
        Map<String, Object> params = new HashMap<>();
        params.put("playerSeq", ownedPlayerSeq);
        params.put("buildId", buildId);
        return buildDAO.insertOwnedBuild(params);
    }

    @Override
    public int unassignBuildFromPlayer(int ownedPlayerSeq, int buildId) {
        Map<String, Object> params = new HashMap<>();
        params.put("playerSeq", ownedPlayerSeq);
        params.put("buildId", buildId);
        return buildDAO.deleteOwnedBuild(params);
    }

    @Override
    public List<BuildDTO> getBuildsByOwnedPlayerSeq(int ownedPlayerSeq) {
        return buildDAO.selectBuildsByOwnedPlayerSeq(ownedPlayerSeq);
    }

    @Override
    public void recordBuildResult(int buildId, boolean isWin) {
        if (buildId <= 0) return;
        if (isWin) {
            buildDAO.incrementBuildWin(buildId);
        } else {
            buildDAO.incrementBuildLose(buildId);
        }
    }
}