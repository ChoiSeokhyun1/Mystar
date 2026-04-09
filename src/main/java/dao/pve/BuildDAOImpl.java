package dao.pve;

import dto.pve.BuildDTO;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
public class BuildDAOImpl implements BuildDAO {

    private static final String NS = "build.";

    @Autowired
    private SqlSessionTemplate sql;

    @Override
    public int insertBuild(BuildDTO build) {
        return sql.insert(NS + "insertBuild", build);
    }

    @Override
    public int updateBuild(BuildDTO build) {
        return sql.update(NS + "updateBuild", build);
    }

    @Override
    public int deleteBuild(int buildId) {
        return sql.delete(NS + "deleteBuild", buildId);
    }

    @Override
    public int nullifyOpponentBuildId(int buildId) {
        return sql.update(NS + "nullifyOpponentBuildId", buildId);
    }

    @Override
    public int deleteOwnedBuildsByBuildId(int buildId) {
        return sql.delete(NS + "deleteOwnedBuildsByBuildId", buildId);
    }

    @Override
    public BuildDTO selectBuildById(int buildId) {
        return sql.selectOne(NS + "selectBuildById", buildId);
    }

    @Override
    public List<BuildDTO> selectBuildsByUserId(String userId) {
        return sql.selectList(NS + "selectBuildsByUserId", userId);
    }

    @Override
    public List<BuildDTO> selectAllBuilds() {
        return sql.selectList(NS + "selectAllBuilds");
    }

    @Override
    public List<BuildDTO> selectBuildsByRace(String race) {
        return sql.selectList(NS + "selectBuildsByRace", race);
    }

    @Override
    public List<BuildDTO> selectSystemBuilds() {
        return sql.selectList(NS + "selectSystemBuilds");
    }

    @Override
    public List<BuildDTO> selectBuildsByRaceAndVsRace(Map<String, Object> params) {
        return sql.selectList(NS + "selectBuildsByRaceAndVsRace", params);
    }

    @Override
    public int deleteBuildUnitsByBuildId(int buildId) {
        return sql.delete(NS + "deleteBuildUnitsByBuildId", buildId);
    }

    @Override
    public int insertOwnedBuild(Map<String, Object> params) {
        return sql.insert(NS + "insertOwnedBuild", params);
    }

    @Override
    public int deleteOwnedBuild(Map<String, Object> params) {
        return sql.delete(NS + "deleteOwnedBuild", params);
    }

    @Override
    public List<BuildDTO> selectBuildsByOwnedPlayerSeq(int ownedPlayerSeq) {
        return sql.selectList(NS + "selectBuildsByOwnedPlayerSeq", ownedPlayerSeq);
    }

    @Override
    public int incrementBuildWin(int buildId) {
        return sql.update(NS + "incrementBuildWin", buildId);
    }

    @Override
    public int incrementBuildLose(int buildId) {
        return sql.update(NS + "incrementBuildLose", buildId);
    }
}