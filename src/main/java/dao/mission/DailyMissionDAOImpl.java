package dao.mission;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.ibatis.session.SqlSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import dto.mission.DailyMissionDTO;
import dto.mission.UserDailyMissionDTO;

@Repository
public class DailyMissionDAOImpl implements DailyMissionDAO {
    
    @Autowired
    private SqlSession sqlSession;
    
    private static final String NAMESPACE = "mapper.mission.dailyMission";
    
    @Override
    public List<DailyMissionDTO> selectAllActiveMissions() {
        return sqlSession.selectList(NAMESPACE + ".selectAllActiveMissions");
    }
    
    @Override
    public DailyMissionDTO selectMissionById(int missionId) {
        return sqlSession.selectOne(NAMESPACE + ".selectMissionById", missionId);
    }
    
    @Override
    public List<UserDailyMissionDTO> selectUserMissionsToday(String userId) {
        return sqlSession.selectList(NAMESPACE + ".selectUserMissionsToday", userId);
    }
    
    @Override
    public UserDailyMissionDTO selectUserMission(String userId, int missionId) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("missionId", missionId);
        return sqlSession.selectOne(NAMESPACE + ".selectUserMission", params);
    }
    
    @Override
    public int insertUserMission(UserDailyMissionDTO userMission) {
        return sqlSession.insert(NAMESPACE + ".insertUserMission", userMission);
    }
    
    @Override
    public int updateMissionProgress(String userId, int missionId, int currentCount) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("missionId", missionId);
        params.put("currentCount", currentCount);
        return sqlSession.update(NAMESPACE + ".updateMissionProgress", params);
    }
    
    @Override
    public int completeMission(String userId, int missionId) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("missionId", missionId);
        return sqlSession.update(NAMESPACE + ".completeMission", params);
    }
    
    @Override
    public int claimReward(String userId, int missionId) {
        Map<String, Object> params = new HashMap<>();
        params.put("userId", userId);
        params.put("missionId", missionId);
        return sqlSession.update(NAMESPACE + ".claimReward", params);
    }
    
    @Override
    public int checkTodayMissionExists(String userId) {
        return sqlSession.selectOne(NAMESPACE + ".checkTodayMissionExists", userId);
    }
    
    @Override
    public int deleteOldUserMissions(String userId) {
        return sqlSession.delete(NAMESPACE + ".deleteOldUserMissions", userId);
    }
    
    @Override
    public int countCompletableMissions(String userId) {
        Integer count = sqlSession.selectOne(NAMESPACE + ".countCompletableMissions", userId);
        return count != null ? count : 0;
    }
    
    @Override
    public int countClaimableRewards(String userId) {
        Integer count = sqlSession.selectOne(NAMESPACE + ".countClaimableRewards", userId);
        return count != null ? count : 0;
    }
}