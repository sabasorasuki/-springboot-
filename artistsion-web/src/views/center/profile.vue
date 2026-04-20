<template>
  <div class="center-profile-page">
    <div v-if="pageLoading" class="page-loading">
      <i class="el-icon-loading" />
      <span>个人中心加载中…</span>
    </div>

    <el-empty
      v-else-if="pageError"
      :description="pageError"
      :image-size="120"
    />

    <template v-else-if="profile">
      <section class="profile-hero">
        <div class="profile-hero__cover" :style="profileCoverStyle">
          <div class="profile-hero__cover-mask" />
          <div v-if="!profileCoverImage" class="profile-hero__cover-empty">
            <span>{{ isSelf ? '上传背景图，让你的主页更完整' : 'TA 还没有设置头图' }}</span>
          </div>
        </div>

        <div class="profile-hero__body">
          <div class="profile-avatar-shell">
            <el-avatar
              :size="112"
              :src="profileAvatar"
              icon="el-icon-user"
              class="profile-avatar"
            />
          </div>

          <div class="profile-summary">
            <div class="profile-summary__top">
              <div class="profile-title-group">
                <h1 class="profile-name">{{ profileDisplayName }}</h1>
                <div class="profile-meta">
                  <span v-if="profile.username" class="meta-pill">@{{ profile.username }}</span>
                  <span v-if="locationText" class="meta-pill">
                    <i class="el-icon-location-outline" />
                    {{ locationText }}
                  </span>
                </div>
              </div>

              <div class="profile-actions">
                <el-button
                  v-if="isSelf"
                  plain
                  size="small"
                  class="header-action-btn"
                  @click="openEditDialog"
                >
                  编辑个人信息
                </el-button>

                <div class="identity-switch">
                  <span class="identity-switch__label">{{ isSelf ? '身份切换' : '查看身份' }}</span>
                  <el-radio-group v-model="profileViewModeValue" size="small">
                    <el-radio-button label="artist">画师</el-radio-button>
                    <el-radio-button label="client">用户</el-radio-button>
                  </el-radio-group>
                </div>

                <el-button
                  v-if="!isSelf"
                  size="small"
                  class="header-action-btn"
                  :type="isFollowingProfile ? '' : 'primary'"
                  :plain="isFollowingProfile"
                  :loading="followLoading"
                  @click="toggleFollowProfile"
                >
                  {{ isFollowingProfile ? '已关注' : '关注' }}
                </el-button>
              </div>
            </div>

            <p class="profile-bio" :class="{ 'is-empty': !profile.bio }">
              {{ profile.bio || '这个人还没有留下简介。' }}
            </p>

            <div class="profile-stats">
              <button type="button" class="stat-card is-link" @click="goFollows">
                <span class="stat-card__value">{{ followStats.following }}</span>
                <span class="stat-card__label">{{ isSelf ? '已关注' : '关注' }}</span>
              </button>

              <button type="button" class="stat-card is-link" @click="goFollows">
                <span class="stat-card__value">{{ followStats.followers }}</span>
                <span class="stat-card__label">粉丝</span>
              </button>

              <div class="stat-card">
                <span class="stat-card__value">{{ portfolioCount }}</span>
                <span class="stat-card__label">{{ portfolioLabel }}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section class="profile-shell">
        <div class="profile-shell__tabs">
          <el-tabs v-model="activePrimaryTab" @tab-click="handlePrimaryTabChange">
            <el-tab-pane
              v-for="tab in primaryTabs"
              :key="tab.key"
              :label="tab.label"
              :name="tab.key"
            />
          </el-tabs>

          <div v-if="secondaryTabs.length" class="secondary-tabs">
            <button
              v-for="tab in secondaryTabs"
              :key="tab.key"
              type="button"
              class="secondary-tab"
              :class="{ 'is-active': activeSecondaryTab === tab.key }"
              @click="setSecondaryTab(tab.key)"
            >
              {{ tab.label }}
            </button>
          </div>
        </div>

        <div class="profile-shell__content">
          <template v-if="isSelf">
            <section v-if="activePrimaryTab === 'submissions'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">我的投稿</h2>
                  <p class="section-heading__desc">画师身份下管理自己的作品与橱窗。</p>
                </div>
                <el-button
                  size="small"
                  type="primary"
                  @click="goPublishEntry(activeSecondaryTab)"
                >
                  {{ activeSecondaryTab === 'showcase' ? '发布橱窗' : '发布作品' }}
                </el-button>
              </div>

              <div v-if="activeSecondaryTab === 'works'">
                <div v-if="works.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                <div v-else-if="works.list.length" class="card-grid">
                  <article v-for="item in works.list" :key="item.id" class="content-card">
                    <div class="content-card__cover">
                      <img
                        v-if="item.photoUrl && !item.photoBroken"
                        :src="item.photoUrl"
                        alt=""
                        class="cover-img"
                        @error="handleCardImageError(item)"
                      >
                      <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                    </div>
                    <div class="content-card__body">
                      <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                      <div class="content-card__meta">
                        <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        <span v-if="item.fbdate" class="meta-note">{{ item.fbdate }}</span>
                      </div>
                    </div>
                  </article>
                </div>
                <el-empty v-else description="还没有投稿作品" :image-size="110" />
              </div>

              <div v-else>
                <div v-if="showcase.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
                <div v-else-if="showcase.list.length" class="card-grid">
                  <article
                    v-for="item in showcase.list"
                    :key="item.id"
                    class="content-card is-clickable"
                    @click="goShowcaseDetail(item.id)"
                  >
                    <div class="content-card__cover">
                      <img
                        v-if="item.photoUrl && !item.photoBroken"
                        :src="item.photoUrl"
                        alt=""
                        class="cover-img"
                        @error="handleCardImageError(item)"
                      >
                      <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                      <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                    </div>
                    <div class="content-card__body">
                      <div class="content-card__title">{{ item.name || '未命名橱窗' }}</div>
                      <div class="content-card__meta">
                        <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        <span v-if="item.status" class="meta-note">{{ item.status }}</span>
                      </div>
                    </div>
                  </article>
                </div>
                <el-empty v-else description="还没有橱窗投稿" :image-size="110" />
              </div>
            </section>

            <section v-else-if="activePrimaryTab === 'projects'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">我的企划</h2>
                  <p class="section-heading__desc">用户身份下查看和管理自己发布的企划。</p>
                </div>
                <el-button size="small" type="primary" @click="goPublishEntry('projects')">发布企划</el-button>
              </div>

              <div v-if="projects.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="projects.list.length" class="project-list">
                <article
                  v-for="item in projects.list"
                  :key="item.id"
                  class="project-card is-clickable"
                  @click="goProjectDetail(item.id)"
                >
                  <div class="project-card__main">
                    <div class="project-card__title">{{ item.title }}</div>
                    <p class="project-card__desc">{{ item.description || '暂无企划描述' }}</p>
                  </div>
                  <div class="project-card__side">
                    <span v-if="item.status" class="project-status">{{ item.status }}</span>
                    <span class="project-budget">{{ formatBudget(item) }}</span>
                  </div>
                </article>
              </div>
              <el-empty v-else description="还没有发布企划" :image-size="110" />
            </section>

            <section v-else-if="activePrimaryTab === 'favorites'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">我的收藏</h2>
                  <p class="section-heading__desc">
                    {{ isArtistView ? '画师身份下只展示收藏的企划。' : '用户身份下按作品与橱窗分类查看收藏。' }}
                  </p>
                </div>
              </div>

              <div v-if="favorites.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <template v-else>
                <div v-if="activeSecondaryTab === 'projects'">
                  <div v-if="favoriteProjects.length" class="project-list">
                    <article
                      v-for="item in favoriteProjects"
                      :key="item.id"
                      class="project-card is-clickable"
                      @click="goProjectDetail(item.wzids)"
                    >
                      <div class="project-card__main">
                        <div class="project-card__title">{{ item.title || '未命名企划' }}</div>
                        <p class="project-card__desc">收藏的企划条目</p>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="还没有收藏企划" :image-size="110" />
                </div>

                <div v-else-if="activeSecondaryTab === 'works'">
                  <div v-if="favoriteWorks.length" class="card-grid">
                    <article v-for="item in favoriteWorks" :key="item.id" class="content-card">
                      <div class="content-card__cover">
                        <img
                          v-if="item.photoUrl && !item.photoBroken"
                          :src="item.photoUrl"
                          alt=""
                          class="cover-img"
                          @error="handleCardImageError(item)"
                        >
                        <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                      </div>
                      <div class="content-card__body">
                        <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                        <div class="content-card__meta">
                          <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        </div>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="还没有收藏作品" :image-size="110" />
                </div>

                <div v-else>
                  <div v-if="favoriteShowcase.length" class="card-grid">
                    <article
                      v-for="item in favoriteShowcase"
                      :key="item.id"
                      class="content-card is-clickable"
                      @click="goShowcaseDetail(item.wzids)"
                    >
                      <div class="content-card__cover">
                        <img
                          v-if="item.photoUrl && !item.photoBroken"
                          :src="item.photoUrl"
                          alt=""
                          class="cover-img"
                          @error="handleCardImageError(item)"
                        >
                        <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                        <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                      </div>
                      <div class="content-card__body">
                        <div class="content-card__title">{{ item.title || '未命名橱窗' }}</div>
                        <div class="content-card__meta">
                          <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                        </div>
                      </div>
                    </article>
                  </div>
                  <el-empty v-else description="还没有收藏橱窗" :image-size="110" />
                </div>
              </template>
            </section>

            <section v-else-if="activePrimaryTab === 'cart'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">购物车</h2>
                  <p class="section-heading__desc">这里只展示加入购物车的橱窗商品。</p>
                </div>
                <el-button size="small" plain @click="$router.push('/showcase')">去逛橱窗</el-button>
              </div>

              <div v-if="cart.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="cart.list.length" class="stack-list">
                <article v-for="item in cart.list" :key="item.id" class="stack-card">
                  <img
                    v-if="item.photoUrl && !item.photoBroken"
                    :src="item.photoUrl"
                    class="stack-card__thumb"
                    alt=""
                    @error="handleCardImageError(item)"
                  >
                  <div v-else class="stack-card__thumb stack-card__thumb--empty">
                    <span class="stack-card__thumb-label">暂无封面</span>
                  </div>
                  <div class="stack-card__main">
                    <div class="stack-card__title">{{ item.name || '未命名商品' }}</div>
                    <div class="stack-card__meta">
                      <span class="price-text">¥{{ item.price || 0 }}</span>
                      <span v-if="item.xddate" class="meta-note">{{ item.xddate }}</span>
                    </div>
                  </div>
                  <div class="stack-card__actions">
                    <el-button size="mini" type="primary" @click="openOrdersTab">去支付</el-button>
                    <el-button size="mini" type="text" @click="removeCartItem(item)">移除</el-button>
                  </div>
                </article>
              </div>
              <el-empty v-else description="购物车还是空的" :image-size="110" />
            </section>

            <section v-else class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">订单</h2>
                  <p class="section-heading__desc">统一查看买家或画师视角下的订单记录。</p>
                </div>

                <el-radio-group
                  v-if="hasArtistRole"
                  v-model="orderViewRole"
                  size="small"
                >
                  <el-radio-button label="用户角色">买家</el-radio-button>
                  <el-radio-button label="画师角色">画师</el-radio-button>
                </el-radio-group>
              </div>

              <div v-if="orders.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <el-table v-else-if="orders.list.length" :data="orders.list" class="orders-table">
                <el-table-column prop="name" label="订单内容" min-width="160" show-overflow-tooltip />
                <el-table-column label="价格" width="110">
                  <template slot-scope="{ row }">
                    <span class="price-text">¥{{ row.price || 0 }}</span>
                  </template>
                </el-table-column>
                <el-table-column prop="status" label="状态" width="120">
                  <template slot-scope="{ row }">
                    <el-tag size="small" :type="statusTagType(row.status)">{{ row.status }}</el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="xddate" label="时间" min-width="160" />
              </el-table>
              <el-empty v-else description="还没有订单记录" :image-size="110" />
            </section>
          </template>

          <template v-else>
            <section v-if="activePrimaryTab === 'featuredWorks'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">精选作品</h2>
                  <p class="section-heading__desc">以画师身份查看该用户公开展示的作品。</p>
                </div>
              </div>

              <div v-if="works.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="works.list.length" class="card-grid">
                <article v-for="item in works.list" :key="item.id" class="content-card">
                  <div class="content-card__cover">
                    <img
                      v-if="item.photoUrl && !item.photoBroken"
                      :src="item.photoUrl"
                      alt=""
                      class="cover-img"
                      @error="handleCardImageError(item)"
                    >
                    <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                  </div>
                  <div class="content-card__body">
                    <div class="content-card__title">{{ item.title || '未命名作品' }}</div>
                    <div class="content-card__meta">
                      <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                    </div>
                  </div>
                </article>
              </div>
              <el-empty v-else description="暂无公开作品" :image-size="110" />
            </section>

            <section v-else-if="activePrimaryTab === 'showcase'" class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">橱窗</h2>
                  <p class="section-heading__desc">以画师身份查看该用户公开上架的橱窗内容。</p>
                </div>
              </div>

              <div v-if="showcase.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="showcase.list.length" class="card-grid">
                <article
                  v-for="item in showcase.list"
                  :key="item.id"
                  class="content-card is-clickable"
                  @click="goShowcaseDetail(item.id)"
                >
                  <div class="content-card__cover">
                    <img
                      v-if="item.photoUrl && !item.photoBroken"
                      :src="item.photoUrl"
                      alt=""
                      class="cover-img"
                      @error="handleCardImageError(item)"
                    >
                    <div v-else class="cover-fallback"><span class="cover-fallback__label">暂无封面</span></div>
                    <span v-if="item.price" class="cover-price">¥{{ item.price }}</span>
                  </div>
                  <div class="content-card__body">
                    <div class="content-card__title">{{ item.name || '未命名橱窗' }}</div>
                    <div class="content-card__meta">
                      <span v-if="item.fenlei" class="meta-tag">{{ item.fenlei }}</span>
                    </div>
                  </div>
                </article>
              </div>
              <el-empty v-else description="暂无公开橱窗" :image-size="110" />
            </section>

            <section v-else class="content-section">
              <div class="section-heading">
                <div>
                  <h2 class="section-heading__title">企划</h2>
                  <p class="section-heading__desc">以用户身份查看该用户公开发布的企划。</p>
                </div>
              </div>

              <div v-if="projects.loading" class="content-loading"><i class="el-icon-loading" /> 加载中…</div>
              <div v-else-if="projects.list.length" class="project-list">
                <article
                  v-for="item in projects.list"
                  :key="item.id"
                  class="project-card is-clickable"
                  @click="goProjectDetail(item.id)"
                >
                  <div class="project-card__main">
                    <div class="project-card__title">{{ item.title }}</div>
                    <p class="project-card__desc">{{ item.description || '暂无企划描述' }}</p>
                  </div>
                  <div class="project-card__side">
                    <span v-if="item.status" class="project-status">{{ item.status }}</span>
                    <span class="project-budget">{{ formatBudget(item) }}</span>
                  </div>
                </article>
              </div>
              <el-empty v-else description="暂无公开企划" :image-size="110" />
            </section>
          </template>
        </div>
      </section>

      <el-dialog
        :visible.sync="editDialogVisible"
        title="编辑个人信息"
        width="720px"
        destroy-on-close
      >
        <el-form ref="editForm" :model="editForm" label-width="84px" class="edit-form">
          <div class="edit-form__hint">在同一个面板里完成基础资料、头像和头图调整。上传完成后点击保存，即会同步刷新个人中心和顶栏头像。</div>
          <div class="edit-media-grid">
            <section class="edit-media-card edit-media-card--avatar">
              <div class="edit-media-card__header">
                <span class="edit-media-card__title">头像</span>
                <span class="edit-media-card__desc">上传后点击保存生效</span>
              </div>
              <div class="edit-avatar-preview">
                <img v-if="editAvatarPreview" :src="editAvatarPreview" alt="" class="edit-avatar-preview__img">
                <div v-else class="edit-avatar-preview__placeholder">暂无头像</div>
              </div>
              <el-upload
                class="edit-upload"
                :action="ossUploadAction('photo')"
                :before-upload="beforeAvatarUpload"
                :show-file-list="false"
                :on-success="handleAvatarUploadSuccess"
                :on-error="handleAvatarUploadError"
              >
                <el-button size="small" plain :loading="avatarUploading">上传新头像</el-button>
              </el-upload>
            </section>

            <section class="edit-media-card edit-media-card--cover">
              <div class="edit-media-card__header">
                <span class="edit-media-card__title">背景图</span>
                <span class="edit-media-card__desc">建议横向图片，个人主页头图会在保存后更新</span>
              </div>
              <div class="edit-cover-preview" :style="editCoverPreviewStyle">
                <div class="edit-cover-preview__mask" />
                <span v-if="!editCoverPreview" class="edit-cover-preview__placeholder">暂无背景图</span>
              </div>
              <el-upload
                class="edit-upload"
                :action="ossUploadAction('photo')"
                :before-upload="beforeCoverUpload"
                :show-file-list="false"
                :on-success="handleCoverUploadSuccess"
                :on-error="handleCoverUploadError"
              >
                <el-button size="small" plain :loading="coverUploading">上传新背景图</el-button>
              </el-upload>
            </section>
          </div>
          <el-form-item label="用户名">
            <el-input v-model="editForm.username" disabled />
          </el-form-item>
          <el-form-item label="昵称">
            <el-input v-model="editForm.name" placeholder="请输入昵称" />
          </el-form-item>
          <el-form-item v-if="locationText" label="地区">
            <el-input :value="locationText" disabled />
          </el-form-item>
          <el-form-item label="邮箱">
            <el-input v-model="editForm.email" placeholder="请输入邮箱" />
          </el-form-item>
          <el-form-item label="电话">
            <el-input v-model="editForm.phone" placeholder="请输入电话" />
          </el-form-item>
          <el-form-item label="简介">
            <el-input
              v-model="editForm.bio"
              type="textarea"
              :rows="4"
              maxlength="500"
              show-word-limit
              placeholder="介绍一下自己"
            />
          </el-form-item>
          <el-form-item label="风格标签">
            <el-input
              v-model="editForm.styleTags"
              placeholder="多个标签用逗号分隔，例如：国风,厚涂,Q版"
            />
          </el-form-item>
        </el-form>

        <div slot="footer" class="dialog-footer">
          <el-button @click="editDialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="saving" @click="handleSaveProfile">保存</el-button>
        </div>
      </el-dialog>
    </template>
  </div>
</template>

<script>
import { mapGetters } from 'vuex'
import userApi from '@/api/userManage'
import followApi from '@/api/follow'
import fenxiangApi from '@/api/fenxiang'
import huagaoApi from '@/api/huagao'
import projectApi from '@/api/project'
import shoucangApi from '@/api/shoucang'
import orderApi from '@/api/order'
import { extractUploadFileName, normalizeImageUrl, ossUploadAction } from '@/utils/oss'
import {
  buildCenterProfileRoute,
  getCenterProfileConfig,
  normalizeProfileViewMode,
  resolveCenterProfileState
} from '@/utils/centerProfile'

const defaultAvatar = 'https://cube.elemecdn.com/3/7c/3ea6beec64369c2642b92c6726f1epng.png'

function createListState(pageSize = 8) {
  return {
    list: [],
    total: 0,
    pageNo: 1,
    pageSize,
    loading: false,
    loaded: false
  }
}

function isSameRouteQueryValue(left, right) {
  return (left || '') === (right || '')
}

function isSameProfileLocation(route, target) {
  const currentQuery = route.query || {}
  const targetQuery = target.query || {}

  return route.path === target.path &&
    isSameRouteQueryValue(currentQuery.view, targetQuery.view) &&
    isSameRouteQueryValue(currentQuery.tab, targetQuery.tab) &&
    isSameRouteQueryValue(currentQuery.sub, targetQuery.sub)
}

export default {
  name: 'CenterProfile',
  data() {
    return {
      defaultAvatar,
      pageLoading: true,
      pageError: '',
      currentUser: null,
      profile: null,
      profileUserId: null,
      isSelf: false,
      otherDisplayMode: 'artist',
      editDialogVisible: false,
      saving: false,
      avatarUploading: false,
      coverUploading: false,
      followLoading: false,
      isFollowingProfile: false,
      editForm: {
        id: null,
        username: '',
        name: '',
        email: '',
        phone: '',
        bio: '',
        styleTags: '',
        avatar: '',
        coverImage: ''
      },
      followStats: {
        following: 0,
        followers: 0
      },
      activePrimaryTab: 'submissions',
      activeSecondaryTab: 'works',
      orderViewRole: '用户角色',
      works: createListState(),
      showcase: createListState(),
      projects: createListState(),
      favorites: createListState(99),
      cart: createListState(6),
      orders: createListState(6)
    }
  },
  computed: {
    ...mapGetters(['token', 'userId', 'displayMode', 'roles', 'activeRole']),
    profileViewModeValue: {
      get() {
        return this.isSelf
          ? normalizeProfileViewMode(this.displayMode, 'client')
          : this.otherDisplayMode
      },
      set(nextMode) {
        this.handleProfileModeChange(nextMode)
      }
    },
    hasArtistRole() {
      return Array.isArray(this.roles) && this.roles.includes('画师角色')
    },
    currentViewMode() {
      return this.isSelf
        ? normalizeProfileViewMode(this.displayMode, 'client')
        : this.otherDisplayMode
    },
    isArtistView() {
      return this.currentViewMode === 'artist'
    },
    profileSchema() {
      return getCenterProfileConfig(this.isSelf, this.currentViewMode)
    },
    profileDisplayName() {
      if (!this.profile) return '用户'
      return this.profile.name || this.profile.username || '用户'
    },
    profileAvatar() {
      return normalizeImageUrl(this.profile && this.profile.avatar) || this.defaultAvatar
    },
    profileCoverImage() {
      if (!this.profile) return ''
      return normalizeImageUrl(this.profile.coverImage || this.profile.cover || this.profile.backgroundImage || this.profile.background)
    },
    profileCoverStyle() {
      if (!this.profileCoverImage) {
        return {}
      }
      return {
        backgroundImage: `linear-gradient(135deg, rgba(14, 29, 41, 0.12), rgba(14, 29, 41, 0.42)), url("${this.profileCoverImage}")`
      }
    },
    editAvatarPreview() {
      return normalizeImageUrl(this.editForm.avatar) || this.profileAvatar
    },
    editCoverPreview() {
      return normalizeImageUrl(this.editForm.coverImage) || this.profileCoverImage
    },
    editCoverPreviewStyle() {
      if (!this.editCoverPreview) {
        return {}
      }
      return {
        backgroundImage: `linear-gradient(135deg, rgba(14, 29, 41, 0.14), rgba(14, 29, 41, 0.38)), url("${this.editCoverPreview}")`
      }
    },
    locationText() {
      if (!this.profile) return ''
      return this.profile.location || this.profile.region || this.profile.address || ''
    },
    portfolioCount() {
      if (this.currentViewMode === 'artist') {
        return this.works.total + this.showcase.total
      }
      return this.projects.total
    },
    portfolioLabel() {
      if (this.currentViewMode === 'artist') {
        return this.isSelf ? '投稿数' : '作品数'
      }
      return '企划数'
    },
    primaryTabs() {
      return this.profileSchema.primaryTabs || []
    },
    secondaryTabs() {
      return (this.profileSchema.secondaryTabs[this.activePrimaryTab] || []).map(item => ({ ...item }))
    },
    favoriteWorks() {
      return this.favorites.list.filter(item => (!item.price || Number(item.price) === 0) && item.fenlei !== '企划')
    },
    favoriteShowcase() {
      return this.favorites.list.filter(item => item.price && Number(item.price) > 0)
    },
    favoriteProjects() {
      return this.favorites.list.filter(item => item.fenlei === '企划')
    },
    hasPublicProjects() {
      return this.projects.total > 0 || this.projects.list.length > 0
    }
  },
  watch: {
    '$route.fullPath': {
      immediate: true,
      handler() {
        this.handleRouteChange()
      }
    },
    orderViewRole(newValue, oldValue) {
      if (newValue !== oldValue && this.isSelf && this.activePrimaryTab === 'orders') {
        this.orders.pageNo = 1
        this.fetchOrders()
      }
    }
  },
  methods: {
    ossUploadAction,
    async handleRouteChange() {
      const previousProfileUserId = this.profileUserId
      const previousIsSelf = this.isSelf

      try {
        await this.ensureCurrentUser()

        const context = this.resolveProfileContext()
        if (context.shouldCanonicalizeSelfPath) {
          this.replaceProfileRoute({
            viewMode: this.$route.query.view || normalizeProfileViewMode(this.displayMode, 'client'),
            tab: this.$route.query.tab,
            sub: this.$route.query.sub
          })
          return
        }

        const shouldReloadProfile = !this.profile ||
          previousProfileUserId !== context.profileUserId ||
          previousIsSelf !== context.isSelf

        if (shouldReloadProfile) {
          this.pageLoading = true
          this.pageError = ''
          this.profile = null
          this.profileUserId = context.profileUserId
          this.isSelf = context.isSelf
          this.isFollowingProfile = false
          this.followLoading = false
          this.editDialogVisible = false
          this.resetContentState()

          if (context.isSelf) {
            this.profile = { ...this.currentUser }
            this.orderViewRole = this.getDefaultOrderRole(normalizeProfileViewMode(this.displayMode, 'client'))
          } else {
            this.profile = await this.fetchOtherProfile(context.profileUserId)
            this.orderViewRole = '用户角色'
          }

          this.applyProfileToForm(this.profile)

          await Promise.all([
            this.fetchFollowStats(),
            this.fetchWorks(),
            this.fetchShowcase(),
            this.fetchProjects()
          ])

          if (!context.isSelf) {
            await this.checkFollowStatus()
          }
        }

        this.applyRouteState()
        this.ensureSectionData()
      } catch (error) {
        this.pageError = error && error.message ? error.message : '个人中心加载失败'
      } finally {
        this.pageLoading = false
      }
    },
    resolveProfileContext() {
      const routeId = this.normalizeUserId(this.$route.params.id)
      const currentUserId = this.currentUser && this.currentUser.id ? Number(this.currentUser.id) : null

      if (!routeId) {
        if (!currentUserId) {
          throw new Error('请先登录后再查看个人中心')
        }
        return {
          isSelf: true,
          profileUserId: currentUserId,
          shouldCanonicalizeSelfPath: false
        }
      }

      if (currentUserId && routeId === currentUserId) {
        return {
          isSelf: true,
          profileUserId: currentUserId,
          shouldCanonicalizeSelfPath: true
        }
      }

      return {
        isSelf: false,
        profileUserId: routeId,
        shouldCanonicalizeSelfPath: false
      }
    },
    resolveDefaultOtherViewMode() {
      if (this.projects.total > 0 && this.works.total === 0 && this.showcase.total === 0) {
        return 'client'
      }
      return 'artist'
    },
    applyRouteState() {
      const fallbackMode = this.isSelf
        ? normalizeProfileViewMode(this.displayMode, 'client')
        : this.resolveDefaultOtherViewMode()
      const resolvedState = resolveCenterProfileState({
        isSelf: this.isSelf,
        viewMode: this.$route.query.view || fallbackMode,
        tab: this.$route.query.tab,
        sub: this.$route.query.sub
      })

      if (this.isSelf) {
        const nextMode = normalizeProfileViewMode(resolvedState.viewMode, 'client')
        if (nextMode !== this.displayMode) {
          this.$store.commit('user/SET_DISPLAY_MODE', nextMode)
        }
        this.orderViewRole = this.getDefaultOrderRole(nextMode)
      } else {
        this.otherDisplayMode = resolvedState.viewMode
      }

      this.activePrimaryTab = resolvedState.tab
      this.activeSecondaryTab = resolvedState.sub

      this.replaceProfileRoute(resolvedState)
    },
    getDefaultOrderRole(viewMode) {
      return viewMode === 'artist' && this.hasArtistRole ? '画师角色' : '用户角色'
    },
    replaceProfileRoute(state) {
      const target = buildCenterProfileRoute({
        isSelf: this.isSelf,
        userId: this.isSelf ? null : this.profileUserId,
        viewMode: state.viewMode || this.currentViewMode,
        tab: state.tab || this.activePrimaryTab,
        sub: Object.prototype.hasOwnProperty.call(state, 'sub') ? state.sub : this.activeSecondaryTab
      })

      if (!isSameProfileLocation(this.$route, target)) {
        this.$router.replace(target).catch(() => {})
      }
    },
    resetContentState() {
      this.works = createListState()
      this.showcase = createListState()
      this.projects = createListState()
      this.favorites = createListState(99)
      this.cart = createListState(6)
      this.orders = createListState(6)
    },
    normalizeUserId(value) {
      const numeric = Number(value)
      return Number.isFinite(numeric) && numeric > 0 ? numeric : null
    },
    async ensureCurrentUser() {
      if (this.currentUser && this.currentUser.id) return this.currentUser
      if (!this.token) return null

      const res = await userApi.getInfo(this.token)
      const user = res && res.data ? res.data.userList : null
      if (user) {
        this.currentUser = user
      }
      return user
    },
    async fetchOtherProfile(userId) {
      const res = await userApi.getUserById(userId)
      if (!res || !res.data) {
        throw new Error('用户不存在')
      }
      return res.data
    },
    applyProfileToForm(profile) {
      this.editForm = {
        id: profile && profile.id ? profile.id : null,
        username: profile && profile.username ? profile.username : '',
        name: profile && profile.name ? profile.name : '',
        email: profile && profile.email ? profile.email : '',
        phone: profile && profile.phone ? profile.phone : '',
        bio: profile && profile.bio ? profile.bio : '',
        styleTags: profile && profile.styleTags ? profile.styleTags : '',
        avatar: profile && profile.avatar ? profile.avatar : '',
        coverImage: profile && profile.coverImage ? profile.coverImage : ''
      }
    },
    async fetchFollowStats() {
      if (!this.profileUserId) return
      try {
        const res = await followApi.count(this.profileUserId)
        this.followStats = res.data || { following: 0, followers: 0 }
      } catch (error) {
        this.followStats = { following: 0, followers: 0 }
      }
    },
    normalizeMediaItem(item) {
      return {
        ...item,
        photoUrl: normalizeImageUrl(item && item.photo),
        photoBroken: false
      }
    },
    normalizeMediaList(list) {
      return Array.isArray(list) ? list.map(item => this.normalizeMediaItem(item)) : []
    },
    async fetchWorks() {
      this.works.loading = true
      try {
        const res = await fenxiangApi.getList({
          userids: this.profileUserId,
          pageNo: this.works.pageNo,
          pageSize: this.works.pageSize
        })
        this.works.list = this.normalizeMediaList(res.data.rows || [])
        this.works.total = res.data.total || 0
        this.works.loaded = true
      } finally {
        this.works.loading = false
      }
    },
    async fetchShowcase() {
      this.showcase.loading = true
      try {
        const params = {
          shangjiaids: String(this.profileUserId),
          pageNo: this.showcase.pageNo,
          pageSize: this.showcase.pageSize
        }

        if (!this.isSelf) {
          params.type = '上架'
          params.status = '审核成功'
        }

        const res = await huagaoApi.getList(params)
        this.showcase.list = this.normalizeMediaList(res.data.rows || [])
        this.showcase.total = res.data.total || 0
        this.showcase.loaded = true
      } finally {
        this.showcase.loading = false
      }
    },
    async fetchProjects() {
      this.projects.loading = true
      try {
        const res = await projectApi.getList({
          userId: this.profileUserId,
          pageNo: this.projects.pageNo,
          pageSize: this.projects.pageSize
        })
        this.projects.list = res.data.rows || []
        this.projects.total = res.data.total || 0
        this.projects.loaded = true
      } finally {
        this.projects.loading = false
      }
    },
    async fetchFavorites() {
      if (!this.isSelf || !this.profileUserId) return
      this.favorites.loading = true
      try {
        const res = await shoucangApi.getList({
          userids: this.profileUserId,
          pageNo: this.favorites.pageNo,
          pageSize: this.favorites.pageSize
        })
        this.favorites.list = this.normalizeMediaList(res.data.rows || [])
        this.favorites.total = res.data.total || 0
        this.favorites.loaded = true
      } finally {
        this.favorites.loading = false
      }
    },
    async fetchCart() {
      if (!this.isSelf || !this.profileUserId) return
      this.cart.loading = true
      try {
        const res = await orderApi.getList({
          userids: String(this.profileUserId),
          status: '购物车',
          pageNo: this.cart.pageNo,
          pageSize: this.cart.pageSize
        })
        this.cart.list = this.normalizeMediaList(res.data.rows || [])
        this.cart.total = res.data.total || 0
        this.cart.loaded = true
      } finally {
        this.cart.loading = false
      }
    },
    async fetchOrders() {
      if (!this.isSelf) return
      this.orders.loading = true
      try {
        const res = await orderApi.getMine({
          role: this.orderViewRole,
          pageNo: this.orders.pageNo,
          pageSize: this.orders.pageSize
        })
        this.orders.list = res.data.rows || []
        this.orders.total = res.data.total || 0
        this.orders.loaded = true
      } finally {
        this.orders.loading = false
      }
    },
    ensureSectionData() {
      if (this.isSelf && this.activePrimaryTab === 'favorites' && !this.favorites.loaded && !this.favorites.loading) {
        this.fetchFavorites()
      }

      if (this.isSelf && this.activePrimaryTab === 'cart' && !this.cart.loaded && !this.cart.loading) {
        this.fetchCart()
      }

      if (this.isSelf && this.activePrimaryTab === 'orders' && !this.orders.loaded && !this.orders.loading) {
        this.fetchOrders()
      }
    },
    handlePrimaryTabChange() {
      const resolvedState = resolveCenterProfileState({
        isSelf: this.isSelf,
        viewMode: this.currentViewMode,
        tab: this.activePrimaryTab,
        sub: this.activeSecondaryTab
      })
      this.activePrimaryTab = resolvedState.tab
      this.activeSecondaryTab = resolvedState.sub
      this.ensureSectionData()
      this.replaceProfileRoute(resolvedState)
    },
    setPrimaryTab(tabKey) {
      if (tabKey === this.activePrimaryTab) return
      this.activePrimaryTab = tabKey
      this.handlePrimaryTabChange()
    },
    setSecondaryTab(tabKey) {
      if (tabKey === this.activeSecondaryTab) return
      this.activeSecondaryTab = tabKey
      this.ensureSectionData()
      this.replaceProfileRoute({
        viewMode: this.currentViewMode,
        tab: this.activePrimaryTab,
        sub: this.activeSecondaryTab
      })
    },
    handleCardImageError(item) {
      this.$set(item, 'photoBroken', true)
    },
    openEditDialog() {
      this.applyProfileToForm(this.profile)
      this.avatarUploading = false
      this.coverUploading = false
      this.editDialogVisible = true
    },
    beforeAvatarUpload() {
      this.avatarUploading = true
      return true
    },
    beforeCoverUpload() {
      this.coverUploading = true
      return true
    },
    handleProfileModeChange(nextMode) {
      const resolvedMode = normalizeProfileViewMode(nextMode, this.currentViewMode)
      if (resolvedMode === this.currentViewMode) return

      if (this.isSelf) {
        this.$store.commit('user/SET_DISPLAY_MODE', resolvedMode)
        this.orderViewRole = this.getDefaultOrderRole(resolvedMode)
      } else {
        this.otherDisplayMode = resolvedMode
      }

      const resolvedState = resolveCenterProfileState({
        isSelf: this.isSelf,
        viewMode: resolvedMode,
        tab: this.activePrimaryTab,
        sub: this.activeSecondaryTab
      })

      this.activePrimaryTab = resolvedState.tab
      this.activeSecondaryTab = resolvedState.sub
      this.ensureSectionData()
      this.replaceProfileRoute(resolvedState)

      const label = resolvedMode === 'artist' ? '画师' : '用户'
      this.$message.success(`已切换为${label}视图`)
    },
    buildProfilePayload(overrides = {}) {
      return {
        id: this.profile && this.profile.id ? this.profile.id : this.editForm.id,
        username: (this.profile && this.profile.username) || this.editForm.username || '',
        name: Object.prototype.hasOwnProperty.call(overrides, 'name') ? overrides.name : this.editForm.name,
        email: Object.prototype.hasOwnProperty.call(overrides, 'email') ? overrides.email : this.editForm.email,
        phone: Object.prototype.hasOwnProperty.call(overrides, 'phone') ? overrides.phone : this.editForm.phone,
        bio: Object.prototype.hasOwnProperty.call(overrides, 'bio') ? overrides.bio : this.editForm.bio,
        styleTags: Object.prototype.hasOwnProperty.call(overrides, 'styleTags') ? overrides.styleTags : this.editForm.styleTags,
        avatar: Object.prototype.hasOwnProperty.call(overrides, 'avatar') ? overrides.avatar : (this.editForm.avatar || (this.profile && this.profile.avatar) || ''),
        coverImage: Object.prototype.hasOwnProperty.call(overrides, 'coverImage') ? overrides.coverImage : (this.editForm.coverImage || (this.profile && this.profile.coverImage) || '')
      }
    },
    syncProfileState(profile) {
      if (!profile) return
      const nextProfile = { ...profile }
      this.profile = nextProfile
      if (this.isSelf) {
        this.currentUser = nextProfile
      }
      this.applyProfileToForm(nextProfile)
    },
    async refreshSelfProfile() {
      await this.$store.dispatch('user/getInfo')
      const res = await userApi.getInfo(this.token)
      const user = res && res.data ? res.data.userList : null
      if (user) {
        this.syncProfileState(user)
      }
    },
    async checkFollowStatus() {
      const followerId = this.userId || (this.currentUser && this.currentUser.id)
      if (!this.token || !followerId || !this.profileUserId || this.isSelf) {
        this.isFollowingProfile = false
        return
      }

      try {
        const res = await followApi.check({
          followerId,
          followingId: this.profileUserId
        })
        this.isFollowingProfile = !!(res && res.data)
      } catch (error) {
        this.isFollowingProfile = false
      }
    },
    async toggleFollowProfile() {
      const followerId = this.userId || (this.currentUser && this.currentUser.id)
      if (!this.token || !followerId) {
        this.$message.warning('请先登录')
        return
      }
      if (!this.profileUserId || this.isSelf) return

      this.followLoading = true
      try {
        if (this.isFollowingProfile) {
          await followApi.unfollow({
            followerId,
            followingId: this.profileUserId
          })
          this.isFollowingProfile = false
          this.$message.success('已取消关注')
        } else {
          await followApi.follow({
            followerId,
            followingId: this.profileUserId
          })
          this.isFollowingProfile = true
          this.$message.success('关注成功')
        }
        await this.fetchFollowStats()
      } catch (error) {
        this.$message.error('操作失败')
      } finally {
        this.followLoading = false
      }
    },
    async saveProfilePatch(overrides, successMessage) {
      this.saving = true
      try {
        await userApi.updateMyUser(this.buildProfilePayload(overrides))
        await this.refreshSelfProfile()
        this.$message.success(successMessage)
        return true
      } catch (error) {
        this.$message.error('保存失败')
        return false
      } finally {
        this.saving = false
      }
    },
    applyUploadedImage(field, response, loadingKey, successMessage) {
      const fileName = extractUploadFileName(response)
      if (!fileName) {
        this[loadingKey] = false
        this.$message.error((response && response.message) || '上传失败')
        return
      }

      const nextUrl = normalizeImageUrl(fileName)
      if (!nextUrl) {
        this[loadingKey] = false
        this.$message.error('上传返回的图片地址无效')
        return
      }

      this.editForm[field] = nextUrl
      this[loadingKey] = false
      this.$message.success(successMessage)
    },
    handleAvatarUploadSuccess(response) {
      this.applyUploadedImage('avatar', response, 'avatarUploading', '头像上传成功，保存后生效')
    },
    handleAvatarUploadError() {
      this.avatarUploading = false
      this.$message.error('头像上传失败')
    },
    handleCoverUploadSuccess(response) {
      this.applyUploadedImage('coverImage', response, 'coverUploading', '背景图上传成功，保存后生效')
    },
    handleCoverUploadError() {
      this.coverUploading = false
      this.$message.error('背景图上传失败')
    },
    async handleSaveProfile() {
      const success = await this.saveProfilePatch({}, '个人资料已更新')
      if (success) {
        this.editDialogVisible = false
      }
    },
    goFollows() {
      this.$router.push('/center/follows')
    },
    goPublishEntry(type) {
      if (type === 'projects') {
        this.$router.push('/publish/project')
        return
      }
      const query = type === 'showcase' ? { type: 'huagao' } : undefined
      this.$router.push({ path: '/publish/work', query })
    },
    goShowcaseDetail(id) {
      if (!id) return
      this.$router.push('/work/' + id)
    },
    goProjectDetail(id) {
      if (!id) return
      this.$router.push('/project/' + id)
    },
    openOrdersTab() {
      const wasOrdersTab = this.activePrimaryTab === 'orders'
      this.setPrimaryTab('orders')
      if (wasOrdersTab) {
        this.fetchOrders()
      }
    },
    async removeCartItem(item) {
      try {
        await orderApi.deleteById(item.id)
        this.$message.success('已从购物车移除')
        this.fetchCart()
      } catch (error) {
        this.$message.error('移除失败')
      }
    },
    formatBudget(item) {
      const min = item && item.budgetMin ? item.budgetMin : null
      const max = item && item.budgetMax ? item.budgetMax : null
      if (min !== null && max !== null) return `预算 ¥${min} - ¥${max}`
      if (min !== null) return `预算 ¥${min} 起`
      if (max !== null) return `预算最高 ¥${max}`
      return '预算待沟通'
    },
    statusTagType(status) {
      const tagMap = {
        '待支付': 'warning',
        '已支付': 'success',
        '已完成': 'success',
        '已取消': 'info',
        '退款中': 'danger'
      }
      return tagMap[status] || ''
    }
  }
}
</script>

<style lang="scss" scoped>
.center-profile-page {
  padding: 12px 0 40px;
}

.page-loading {
  min-height: 360px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  color: #7b8796;
  font-size: 15px;
}

.profile-hero {
  overflow: visible;
}

.profile-hero__cover {
  position: relative;
  height: 260px;
  border-radius: 30px;
  overflow: hidden;
  background:
    radial-gradient(circle at top left, rgba(255, 203, 119, 0.9), transparent 35%),
    radial-gradient(circle at top right, rgba(65, 184, 131, 0.22), transparent 28%),
    linear-gradient(135deg, #1f5c4f 0%, #2e7d69 40%, #f5d48f 100%);
  background-size: cover;
  background-position: center;
  box-shadow: 0 18px 42px rgba(34, 46, 69, 0.14);
}

.profile-hero__cover-mask {
  position: absolute;
  inset: 0;
  background:
    linear-gradient(180deg, rgba(13, 22, 28, 0.12) 0%, rgba(13, 22, 28, 0.34) 100%);
}

.profile-hero__cover-empty {
  position: absolute;
  right: 28px;
  bottom: 24px;
  z-index: 1;
  display: inline-flex;
  padding: 10px 16px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.16);
  backdrop-filter: blur(12px);
  color: #fff7e2;
  font-size: 13px;
}

.profile-hero__body {
  display: flex;
  gap: 28px;
  align-items: flex-start;
  padding: 0 8px;
  margin-top: -72px;
  position: relative;
  z-index: 2;
}

.profile-avatar-shell {
  flex-shrink: 0;
  align-self: flex-start;
  padding: 8px;
  border-radius: 32px;
  background: rgba(255, 255, 255, 0.95);
  box-shadow: 0 20px 38px rgba(34, 46, 69, 0.18);
}

.profile-avatar {
  display: block;
  border: 4px solid rgba(255, 255, 255, 0.88);
}

.profile-summary {
  flex: 1;
  min-width: 0;
  padding: 86px 20px 4px 0;
}

.profile-summary__top {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 20px;
}

.profile-title-group {
  min-width: 0;
}

.profile-name {
  margin: 0;
  font-size: 30px;
  font-weight: 700;
  color: #20313f;
}

.profile-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
  margin-top: 10px;
}

.meta-pill {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  padding: 6px 12px;
  border-radius: 999px;
  background: #eef3f1;
  color: #55646f;
  font-size: 13px;
}

.profile-actions {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  flex-wrap: wrap;
  justify-content: flex-end;
}

.header-action-btn {
  border-radius: 999px;
  min-width: 112px;
  background: rgba(255, 255, 255, 0.92);
  border-color: rgba(176, 189, 198, 0.8);
}

.identity-switch {
  display: flex;
  flex-direction: column;
  gap: 8px;
  padding: 12px;
  border-radius: 18px;
  background: #f6f8f7;
}

.identity-switch__label {
  font-size: 12px;
  color: #7b8796;
}

.profile-bio {
  margin: 18px 0 0;
  font-size: 14px;
  line-height: 1.75;
  color: #55646f;
}

.profile-bio.is-empty {
  color: #97a3ad;
}

.profile-stats {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 14px;
  margin-top: 22px;
}

.stat-card {
  border: 0;
  border-radius: 18px;
  padding: 18px 20px;
  text-align: left;
  background: #f7faf9;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.stat-card.is-link {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 24px rgba(34, 46, 69, 0.08);
  }
}

.stat-card__value {
  font-size: 26px;
  font-weight: 700;
  color: #20313f;
}

.stat-card__label {
  font-size: 13px;
  color: #70808c;
}

.profile-shell {
  margin-top: 18px;
  background: #fff;
  border-radius: 24px;
  box-shadow: 0 14px 40px rgba(34, 46, 69, 0.08);
}

.profile-shell__tabs {
  padding: 24px 28px 0;
}

.profile-shell__tabs ::v-deep .el-tabs__nav-wrap::after {
  background: #edf1f0;
}

.profile-shell__tabs ::v-deep .el-tabs__item {
  font-size: 16px;
  font-weight: 600;
  color: #7b8796;
}

.profile-shell__tabs ::v-deep .el-tabs__item.is-active {
  color: #1f5c4f;
}

.profile-shell__tabs ::v-deep .el-tabs__active-bar {
  background: #1f5c4f;
}

.secondary-tabs {
  display: flex;
  gap: 10px;
  margin-top: 4px;
  margin-bottom: 12px;
  flex-wrap: wrap;
}

.secondary-tab {
  border: 0;
  border-radius: 999px;
  padding: 8px 16px;
  background: #eef3f1;
  color: #70808c;
  font-size: 13px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.secondary-tab.is-active {
  background: #1f5c4f;
  color: #fff;
}

.profile-shell__content {
  padding: 0 28px 28px;
}

.content-section {
  padding-top: 8px;
}

.section-heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  margin-bottom: 22px;
}

.section-heading__title {
  margin: 0;
  font-size: 24px;
  font-weight: 700;
  color: #20313f;
}

.section-heading__desc {
  margin: 6px 0 0;
  color: #7b8796;
  font-size: 14px;
}

.content-loading {
  padding: 48px 0;
  text-align: center;
  color: #97a3ad;
}

.card-grid {
  display: grid;
  grid-template-columns: repeat(4, minmax(0, 1fr));
  gap: 18px;
}

.content-card {
  border-radius: 18px;
  overflow: hidden;
  background: #fff;
  border: 1px solid #edf1f0;
  box-shadow: 0 8px 24px rgba(34, 46, 69, 0.05);
}

.content-card.is-clickable {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;

  &:hover {
    transform: translateY(-3px);
    box-shadow: 0 14px 28px rgba(34, 46, 69, 0.12);
  }
}

.content-card__cover {
  position: relative;
  padding-top: 100%;
  overflow: hidden;
  background: #eef3f1;
}

.cover-img,
.cover-fallback {
  position: absolute;
  inset: 0;
  width: 100%;
  height: 100%;
}

.cover-img {
  object-fit: cover;
}

.cover-fallback {
  display: flex;
  align-items: center;
  justify-content: center;
  background:
    radial-gradient(circle at top left, rgba(245, 212, 143, 0.75), transparent 35%),
    linear-gradient(135deg, #dbe8e2 0%, #eef3f1 100%);
}

.cover-fallback__label {
  font-size: 12px;
  letter-spacing: 1px;
  color: #6f7d88;
}

.cover-price {
  position: absolute;
  right: 12px;
  bottom: 12px;
  padding: 4px 10px;
  border-radius: 999px;
  background: rgba(19, 28, 35, 0.72);
  color: #ffd88a;
  font-size: 12px;
  font-weight: 600;
}

.content-card__body {
  padding: 14px;
}

.content-card__title {
  font-size: 15px;
  font-weight: 600;
  color: #20313f;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.content-card__meta {
  display: flex;
  align-items: center;
  gap: 8px;
  margin-top: 10px;
  flex-wrap: wrap;
}

.meta-tag {
  display: inline-flex;
  align-items: center;
  padding: 4px 10px;
  border-radius: 999px;
  background: #eef3f1;
  color: #1f5c4f;
  font-size: 12px;
}

.meta-note {
  font-size: 12px;
  color: #97a3ad;
}

.project-list,
.stack-list {
  display: flex;
  flex-direction: column;
  gap: 14px;
}

.project-card,
.stack-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 18px;
  padding: 18px 20px;
  border-radius: 18px;
  border: 1px solid #edf1f0;
  background: #fff;
  box-shadow: 0 8px 24px rgba(34, 46, 69, 0.05);
}

.project-card.is-clickable {
  cursor: pointer;
  transition: transform 0.2s ease, box-shadow 0.2s ease;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 14px 28px rgba(34, 46, 69, 0.12);
  }
}

.project-card__main,
.stack-card__main {
  flex: 1;
  min-width: 0;
}

.project-card__title,
.stack-card__title {
  font-size: 16px;
  font-weight: 600;
  color: #20313f;
}

.project-card__desc {
  margin: 8px 0 0;
  color: #7b8796;
  font-size: 14px;
  line-height: 1.7;
}

.project-card__side {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 10px;
  flex-shrink: 0;
}

.project-status {
  padding: 4px 10px;
  border-radius: 999px;
  background: #ecf7f2;
  color: #1f8c68;
  font-size: 12px;
}

.project-budget {
  font-size: 13px;
  color: #7b8796;
}

.stack-card__thumb {
  width: 84px;
  height: 84px;
  border-radius: 14px;
  object-fit: cover;
  background: #eef3f1;
  flex-shrink: 0;
}

.stack-card__thumb--empty {
  display: flex;
  align-items: center;
  justify-content: center;
  background:
    radial-gradient(circle at top left, rgba(245, 212, 143, 0.75), transparent 35%),
    linear-gradient(135deg, #dbe8e2 0%, #eef3f1 100%);
}

.stack-card__thumb-label {
  font-size: 12px;
  color: #6f7d88;
}

.stack-card__meta {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-top: 8px;
}

.stack-card__actions {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  flex-shrink: 0;
}

.price-text {
  color: #d86d3e;
  font-weight: 600;
}

.orders-table {
  width: 100%;
}

.overview-panels {
  display: grid;
  grid-template-columns: repeat(3, minmax(0, 1fr));
  gap: 16px;
  margin-bottom: 28px;
}

.overview-panel {
  padding: 18px 20px;
  border-radius: 18px;
  background: #f7faf9;
}

.overview-panel__label {
  font-size: 13px;
  color: #70808c;
}

.overview-panel__value {
  margin-top: 6px;
  font-size: 30px;
  font-weight: 700;
  color: #20313f;
}

.home-sections {
  display: flex;
  flex-direction: column;
  gap: 28px;
}

.home-block__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;

  h3 {
    margin: 0;
    font-size: 18px;
    color: #20313f;
  }
}

.link-btn {
  border: 0;
  padding: 0;
  background: transparent;
  color: #1f5c4f;
  font-size: 13px;
  cursor: pointer;
}

.edit-form {
  padding-top: 8px;
}

.edit-form__hint {
  margin-bottom: 18px;
  padding: 12px 14px;
  border-radius: 14px;
  background: #f7faf9;
  color: #70808c;
  font-size: 13px;
  line-height: 1.6;
}

.edit-media-grid {
  display: grid;
  grid-template-columns: 220px minmax(0, 1fr);
  gap: 18px;
  margin-bottom: 22px;
}

.edit-media-card {
  border-radius: 20px;
  border: 1px solid #e7ecea;
  background: #fbfdfc;
  padding: 16px;
}

.edit-media-card__header {
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 12px;
}

.edit-media-card__title {
  font-size: 15px;
  font-weight: 600;
  color: #20313f;
}

.edit-media-card__desc {
  font-size: 12px;
  color: #7b8796;
}

.edit-avatar-preview {
  width: 132px;
  height: 132px;
  margin-bottom: 12px;
  border-radius: 28px;
  overflow: hidden;
  background: linear-gradient(135deg, #eff3f1 0%, #f7faf8 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.edit-avatar-preview__img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.edit-avatar-preview__placeholder,
.edit-cover-preview__placeholder {
  font-size: 13px;
  color: #7b8796;
}

.edit-cover-preview {
  position: relative;
  min-height: 148px;
  margin-bottom: 12px;
  border-radius: 24px;
  overflow: hidden;
  background:
    radial-gradient(circle at top left, rgba(255, 203, 119, 0.9), transparent 35%),
    radial-gradient(circle at top right, rgba(65, 184, 131, 0.22), transparent 28%),
    linear-gradient(135deg, #1f5c4f 0%, #2e7d69 40%, #f5d48f 100%);
  background-size: cover;
  background-position: center;
  display: flex;
  align-items: center;
  justify-content: center;
}

.edit-cover-preview__mask {
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(13, 22, 28, 0.08) 0%, rgba(13, 22, 28, 0.26) 100%);
}

.edit-cover-preview__placeholder {
  position: relative;
  z-index: 1;
  color: #f5f7eb;
}

.edit-upload ::v-deep .el-upload {
  display: inline-flex;
}

@media (max-width: 1024px) {
  .card-grid {
    grid-template-columns: repeat(3, minmax(0, 1fr));
  }
}

@media (max-width: 768px) {
  .profile-hero__cover {
    height: 210px;
  }

  .profile-hero__body {
    flex-direction: column;
    align-items: stretch;
    padding: 0;
    margin-top: -56px;
  }

  .profile-summary__top,
  .section-heading {
    flex-direction: column;
    align-items: flex-start;
  }

  .profile-summary {
    padding: 20px 0 4px;
  }

  .profile-actions {
    width: 100%;
    justify-content: flex-start;
  }

  .profile-stats,
  .overview-panels {
    grid-template-columns: 1fr;
  }

  .edit-media-grid {
    grid-template-columns: 1fr;
  }

  .card-grid {
    grid-template-columns: repeat(2, minmax(0, 1fr));
  }

  .profile-shell__tabs,
  .profile-shell__content {
    padding-left: 20px;
    padding-right: 20px;
  }

  .project-card,
  .stack-card {
    flex-direction: column;
    align-items: flex-start;
  }

  .project-card__side,
  .stack-card__actions {
    align-items: flex-start;
  }
}

@media (max-width: 520px) {
  .profile-name {
    font-size: 24px;
  }

  .card-grid {
    grid-template-columns: 1fr;
  }
}
</style>
