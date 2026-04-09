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
        
        // ---------------------------------------------------------
        // [수정됨] 기존 종족 기반 상성 저장 로직 주석(삭제) 처리
        // '빌드 vs 빌드' 상성 시스템 도입으로 인해 상성은 대본 관리 페이지에서 개별 저장됩니다.
        /*
        scriptDAO.deleteMatchupsByBuildId(buildId);
        if (build.getMatchups() != null) {
            for (BuildMatchupDTO m : build.getMatchups()) {
                m.setBuildId(buildId); // 에러 발생 지점 해결
                scriptDAO.insertOrUpdateMatchup(m);
            }
        }
        */
        // ---------------------------------------------------------

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
        // 빌드 삭제 시 구버전 상성 삭제 쿼리도 에러 방지를 위해 주석 처리합니다.
        // scriptDAO.deleteMatchupsByBuildId(buildId);
        
        scriptDAO.deleteStatBonusesByBuildId(buildId);
        scriptDAO.deleteScriptsByMyBuildId(buildId);
        buildDAO.nullifyOpponentBuildId(buildId);
        buildDAO.deleteOwnedBuildsByBuildId(buildId);
        buildDAO.deleteBuildUnitsByBuildId(buildId);
        return buildDAO.deleteBuild(buildId);
    }

    @Override
    public BuildDTO getBuildById(int buildId) {
        BuildDTO build = buildDAO.selectBuildById(buildId);
        if (build != null) {
            build.setStatBonuses(scriptDAO.selectStatBonusesByBuildId(buildId));
        }
        return build;
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