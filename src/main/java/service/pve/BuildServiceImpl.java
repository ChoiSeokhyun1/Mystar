package service.pve;

import dao.pve.BuildDAO;
import dao.pve.ScriptDAO;
import dto.pve.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class BuildServiceImpl implements BuildService {

    @Autowired private BuildDAO  buildDAO;
    @Autowired private ScriptDAO scriptDAO;

    /** 상성/가산점/대본 일괄 저장 */
    private void saveScriptData(int buildId, BuildDTO build) {
        // 상성
        scriptDAO.deleteMatchupsByBuildId(buildId);
        if (build.getMatchups() != null) {
            for (BuildMatchupDTO m : build.getMatchups()) {
                m.setBuildId(buildId);
                scriptDAO.insertOrUpdateMatchup(m);
            }
        }
        // 능력치 가산점
        scriptDAO.deleteStatBonusesByBuildId(buildId);
        if (build.getStatBonuses() != null) {
            for (BuildStatBonusDTO b : build.getStatBonuses()) {
                b.setBuildId(buildId);
                scriptDAO.insertOrUpdateStatBonus(b);
            }
        }
        // 대본
        scriptDAO.deleteScriptsByMyBuildId(buildId);
        if (build.getScripts() != null) {
            for (ScriptDTO s : build.getScripts()) {
                if (s.getMyBuildId() == 0) {
                    s.setMyBuildId(buildId);
                }
                scriptDAO.insertScript(s);
            }
        }
    }

    @Override
    public int createBuild(BuildDTO build) {
        int result = buildDAO.insertBuild(build);
        saveScriptData(build.getBuildId(), build);
        return result;
    }

    @Override
    public int modifyBuild(BuildDTO build) {
        int result = buildDAO.updateBuild(build);
        saveScriptData(build.getBuildId(), build);
        return result;
    }

    @Override
    public int removeBuild(int buildId) {
        scriptDAO.deleteMatchupsByBuildId(buildId);
        scriptDAO.deleteStatBonusesByBuildId(buildId);
        scriptDAO.deleteScriptsByMyBuildId(buildId);
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