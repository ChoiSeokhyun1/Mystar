package service.pve;

import dao.pve.BuildDAO;
import dto.pve.BuildDTO;
import dto.pve.BuildUnitDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class BuildServiceImpl implements BuildService {

    @Autowired
    private BuildDAO buildDAO;

    // ── 빌드 생성 (빌드 마스터 + 유닛 한번에)
    @Override
    public int createBuild(BuildDTO build) {
        // 1. 빌드 마스터 저장
        int result = buildDAO.insertBuild(build);

        // 2. 유닛 설정 저장
        if (build.getUnits() != null) {
            for (BuildUnitDTO unit : build.getUnits()) {
                unit.setBuildId(build.getBuildId());
                buildDAO.insertBuildUnit(unit);
            }
        }
        return result;
    }

    // ── 빌드 수정 (유닛은 전체 삭제 후 재삽입)
    @Override
    public int modifyBuild(BuildDTO build) {
        int result = buildDAO.updateBuild(build);

        // 기존 유닛 전체 삭제 후 재삽입
        buildDAO.deleteBuildUnitsByBuildId(build.getBuildId());
        if (build.getUnits() != null) {
            for (BuildUnitDTO unit : build.getUnits()) {
                unit.setBuildId(build.getBuildId());
                buildDAO.insertBuildUnit(unit);
            }
        }
        return result;
    }

    // ── 빌드 삭제 (FK 순서: opponents NULL화 → owned 삭제 → units 삭제 → 본체 삭제)
    @Override
    public int removeBuild(int buildId) {
        buildDAO.nullifyOpponentBuildId(buildId);   // 1. PVE 상대 BUILD_ID → NULL
        buildDAO.deleteOwnedBuildsByBuildId(buildId); // 2. 선수-빌드 연결 삭제
        buildDAO.deleteBuildUnitsByBuildId(buildId);  // 3. 유닛 설정 삭제
        return buildDAO.deleteBuild(buildId);          // 4. 빌드 본체 삭제
    }

    @Override
    public BuildDTO getBuildById(int buildId) {
        return buildDAO.selectBuildById(buildId);
    }

    @Override
    public List<BuildDTO> getBuildsByUserId(String userId) {
        return buildDAO.selectBuildsByUserId(userId);
    }

    // ── 선수에게 빌드 배정
    @Override
    public int assignBuildToPlayer(int ownedPlayerSeq, int buildId) {
        Map<String, Object> params = new HashMap<>();
        params.put("playerSeq", ownedPlayerSeq);
        params.put("buildId", buildId);
        return buildDAO.insertOwnedBuild(params);
    }

    // ── 선수-빌드 연결 해제
    @Override
    public int unassignBuildFromPlayer(int ownedPlayerSeq, int buildId) {
        Map<String, Object> params = new HashMap<>();
        params.put("playerSeq", ownedPlayerSeq);
        params.put("buildId", buildId);
        return buildDAO.deleteOwnedBuild(params);
    }

    // ── 선수가 사용 가능한 빌드 목록
    @Override
    public List<BuildDTO> getBuildsByOwnedPlayerSeq(int ownedPlayerSeq) {
        return buildDAO.selectBuildsByOwnedPlayerSeq(ownedPlayerSeq);
    }

    // ── 빌드 전적 기록 (세트 결과 반영)
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